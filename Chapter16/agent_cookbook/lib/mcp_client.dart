import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tool.dart';

/// Connects to an MCP server over HTTP, discovers its tools, and exposes
/// them as the standard [Tool] interface used by [AgentRunner].
///
/// This approach works on iOS, Android, and desktop because it uses plain
/// HTTP instead of spawning a child process.
class McpClient {
  final String _baseUrl;
  int _nextId = 1;

  McpClient._(this._baseUrl);

  /// Sends the MCP initialization handshake and returns a ready client.
  static Future<McpClient> connect(String baseUrl) async {
    final client = McpClient._(baseUrl);
    await client._send('initialize', {
      'protocolVersion': '2025-06-18',
      'capabilities': {},
      'clientInfo': {
        'name': 'flutter-agent',
        'version': '1.0.0',
      },
    });
    return client;
  }

  Future<Map<String, dynamic>> _send(
    String method,
    Map<String, dynamic> params,
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'id': _nextId++,
        'method': method,
        'params': params,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('MCP error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['result'] as Map<String, dynamic>;
  }

  /// Discovers tools from the server and wraps each as an [McpTool].
  Future<List<McpTool>> listTools() async {
    final result = await _send('tools/list', {});
    final tools = result['tools'] as List;
    return tools.map((t) {
      final def = t as Map<String, dynamic>;
      return McpTool(
        client: this,
        mcpName: def['name'] as String,
        mcpDescription: def['description'] as String,
        mcpParameters: def['inputSchema'] as Map<String, dynamic>,
      );
    }).toList();
  }

  /// Calls a named tool with [args] and returns the text result.
  Future<String> callTool(
    String name,
    Map<String, dynamic> args,
  ) async {
    final result = await _send(
      'tools/call',
      {'name': name, 'arguments': args},
    );
    final content = result['content'] as List;
    return content.map((c) => c['text']).join('\n');
  }
}

/// Bridges an MCP tool definition to the agent's [Tool] interface.
class McpTool extends Tool {
  final McpClient client;

  @override
  final String name;
  @override
  final String description;
  @override
  final Map<String, dynamic> parameters;

  McpTool({
    required this.client,
    required String mcpName,
    required String mcpDescription,
    required Map<String, dynamic> mcpParameters,
  })  : name = mcpName,
        description = mcpDescription,
        parameters = mcpParameters;

  @override
  Future<String> execute(Map<String, dynamic> input) =>
      client.callTool(name, input);
}
