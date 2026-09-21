import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

// In-memory notes storage (shared across both transports).
final _notes = <String, String>{
  'shopping': 'Milk, eggs, bread',
  'todo': 'Finish chapter 5, review PR',
};

void main(List<String> args) async {
  if (args.contains('--http')) {
    await _serveHttp();
  } else {
    NotesServer(stdioChannel(input: io.stdin, output: io.stdout));
  }
}

// ---------------------------------------------------------------------------
// HTTP transport (for Flutter / mobile clients)
// ---------------------------------------------------------------------------

Future<void> _serveHttp() async {
  Future<shelf.Response> handler(shelf.Request request) async {
    if (request.method != 'POST') {
      return shelf.Response(405);
    }

    final body = await request.readAsString();
    final jsonReq = jsonDecode(body) as Map<String, dynamic>;
    final method = jsonReq['method'] as String;
    final id = jsonReq['id'];
    final params =
        jsonReq['params'] as Map<String, dynamic>? ?? {};

    Map<String, dynamic> result;
    switch (method) {
      case 'initialize':
        result = {
          'protocolVersion': '2025-06-18',
          'capabilities': {'tools': {}},
          'serverInfo': {
            'name': 'notes-server',
            'version': '1.0.0',
          },
        };
      case 'tools/list':
        result = {
          'tools': [
            {
              'name': 'list_notes',
              'description': 'List all note titles.',
              'inputSchema': {
                'type': 'object',
                'properties': {},
              },
            },
            {
              'name': 'get_note',
              'description': 'Get a note by title.',
              'inputSchema': {
                'type': 'object',
                'properties': {
                  'title': {
                    'type': 'string',
                    'description': 'The note title',
                  },
                },
              },
            },
            {
              'name': 'create_note',
              'description': 'Create or update a note.',
              'inputSchema': {
                'type': 'object',
                'properties': {
                  'title': {
                    'type': 'string',
                    'description': 'The note title',
                  },
                  'content': {
                    'type': 'string',
                    'description': 'The note content',
                  },
                },
              },
            },
          ],
        };
      case 'tools/call':
        result = _handleToolCall(params);
      default:
        result = {};
    }

    return shelf.Response.ok(
      jsonEncode({'jsonrpc': '2.0', 'id': id, 'result': result}),
      headers: {'content-type': 'application/json'},
    );
  }

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('MCP server running on '
      'http://${server.address.host}:${server.port}');
}

Map<String, dynamic> _handleToolCall(Map<String, dynamic> params) {
  final name = params['name'] as String;
  final args =
      params['arguments'] as Map<String, dynamic>? ?? {};

  String text;
  switch (name) {
    case 'list_notes':
      text = _notes.keys.join(', ');
    case 'get_note':
      final title = args['title'] as String;
      text = _notes[title] ?? 'Note not found: $title';
    case 'create_note':
      final title = args['title'] as String;
      _notes[title] = args['content'] as String;
      text = 'Created note: $title';
    default:
      text = 'Unknown tool: $name';
  }

  return {
    'content': [
      {'type': 'text', 'text': text},
    ],
  };
}

// ---------------------------------------------------------------------------
// stdio transport (for Gemini CLI, Claude Desktop, etc.)
// ---------------------------------------------------------------------------

/// An MCP server that exposes three tools for managing in-memory notes.
base class NotesServer extends MCPServer with ToolsSupport {
  NotesServer(super.channel)
      : super.fromStreamChannel(
          implementation: Implementation(
            name: 'notes-server',
            version: '1.0.0',
          ),
          instructions: 'Manage in-memory notes using list_notes, '
              'get_note, and create_note tools.',
        ) {
    registerTool(_listNotesTool, _handleListNotes);
    registerTool(_getNoteTool, _handleGetNote);
    registerTool(_createNoteTool, _handleCreateNote);
  }

  // ── Tool definitions ──────────────────────────────────────────────────────

  final _listNotesTool = Tool(
    name: 'list_notes',
    description: 'List all note titles.',
    inputSchema: Schema.object(),
  );

  final _getNoteTool = Tool(
    name: 'get_note',
    description: 'Get a note by title.',
    inputSchema: Schema.object(
      properties: {
        'title': Schema.string(description: 'The note title'),
      },
      required: ['title'],
    ),
  );

  final _createNoteTool = Tool(
    name: 'create_note',
    description: 'Create or update a note.',
    inputSchema: Schema.object(
      properties: {
        'title': Schema.string(description: 'The note title'),
        'content': Schema.string(description: 'The note content'),
      },
      required: ['title', 'content'],
    ),
  );

  // ── Tool handlers ─────────────────────────────────────────────────────────

  CallToolResult _handleListNotes(CallToolRequest request) {
    final titles = _notes.keys.join(', ');
    return CallToolResult(
      content: [TextContent(text: titles.isEmpty ? '(no notes)' : titles)],
    );
  }

  CallToolResult _handleGetNote(CallToolRequest request) {
    final title = request.arguments!['title'] as String;
    final content = _notes[title] ?? 'Note not found';
    return CallToolResult(content: [TextContent(text: content)]);
  }

  CallToolResult _handleCreateNote(CallToolRequest request) {
    final title = request.arguments!['title'] as String;
    final content = request.arguments!['content'] as String;
    _notes[title] = content;
    return CallToolResult(
      content: [TextContent(text: 'Created note: $title')],
    );
  }
}
