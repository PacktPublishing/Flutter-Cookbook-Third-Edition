import 'dart:convert';
import 'package:http/http.dart' as http;
import 'agent_callbacks.dart';
import 'tool.dart';

class AgentException implements Exception {
  final String message;

  AgentException(this.message);

  @override
  String toString() => 'AgentException: $message';
}

/// Returns the parts of the model's reply, or throws if it
/// sent none. A reply can arrive empty: a safety block, a
/// token limit, or a malformed function call.
List<dynamic> partsOrThrow(Map<String, dynamic> response) {
  final candidate = response['candidates'][0];
  final content =
      candidate['content'] as Map<String, dynamic>?;
  final parts = content?['parts'] as List?;
  if (parts == null || parts.isEmpty) {
    throw AgentException(
      'No content from the model '
      '(finishReason: ${candidate['finishReason']}).',
    );
  }
  return parts;
}

class AgentRunner {
  final String apiKey;
  final String model;
  final int maxIterations;
  final int maxHistoryEntries;
  final Map<String, Tool> _tools = {};
  final List<Map<String, dynamic>> _history = [];

  AgentRunner({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
    this.maxIterations = 8,
    this.maxHistoryEntries = 20,
  });

  void registerTool(Tool tool) {
    _tools[tool.name] = tool;
  }

  void reset() => _history.clear();

  /// Runs the agentic loop for [userMessage]. An optional
  /// [systemInstruction] steers this turn without adding to
  /// history, so user/model turns stay strictly alternating.
  Future<String> run(
    String userMessage, {
    AgentCallbacks? callbacks,
    String? systemInstruction,
  }) async {
    _history.add({
      'role': 'user',
      'parts': [{'text': userMessage}],
    });

    // The agentic loop: keep going until the model returns
    // a final text response, up to maxIterations rounds.
    for (var i = 0; i < maxIterations; i++) {
      final response = await _callLLM(
        _history,
        systemInstruction: systemInstruction,
      );
      final parts = partsOrThrow(response);

      final functionCalls = parts
          .cast<Map<String, dynamic>>()
          .where((p) => p.containsKey('functionCall'))
          .toList();

      // No function calls — the model is done.
      if (functionCalls.isEmpty) {
        final finalText = parts
            .cast<Map<String, dynamic>>()
            .where((p) => p.containsKey('text'))
            .map((p) => p['text'] as String)
            .join('\n');

        // Record the answer so the model can see it next turn.
        _history.add({
          'role': 'model',
          'parts': [{'text': finalText}],
        });
        _trimHistory();
        callbacks?.onComplete?.call(finalText);
        return finalText;
      }

      _history.add({
        'role': 'model',
        'parts': parts,
      });

      final responseParts = <Map<String, dynamic>>[];
      for (final part in functionCalls) {
        final fc = part['functionCall'] as Map<String, dynamic>;
        final toolName = fc['name'] as String;
        final toolArgs =
            Map<String, dynamic>.from(fc['args'] ?? {});

        callbacks?.onToolCall?.call(toolName, toolArgs);

        // Tool failures go back to the model as text so it
        // can recover, instead of crashing the loop.
        final tool = _tools[toolName];
        String result;
        if (tool == null) {
          result = 'Error: no tool named $toolName is available.';
        } else {
          try {
            result = await tool.execute(toolArgs);
          } catch (e) {
            result = 'Error: $e';
          }
        }

        // Fires for error strings too, so the UI shows failures.
        callbacks?.onToolResult?.call(toolName, result);

        responseParts.add({
          'functionResponse': {
            'name': toolName,
            'response': {'result': result},
          },
        });
      }

      _history.add({
        'role': 'user',
        'parts': responseParts,
      });
      // Loop continues — the model will see the results and
      // either call another function or return a final answer.
    }

    throw AgentException(
      'No final answer after $maxIterations iterations. '
      'The model is probably stuck in a tool-calling loop.',
    );
  }

  // A tool result is also stored with role 'user', so the role
  // alone does not identify a real user turn. Only an entry that
  // carries text does.
  bool _isUserMessage(Map<String, dynamic> entry) {
    if (entry['role'] != 'user') return false;
    final parts = entry['parts'] as List;
    return parts.any(
      (p) => (p as Map).containsKey('text'),
    );
  }

  // Drops the oldest entries once the history grows past
  // maxHistoryEntries, always cutting at a user message so no
  // functionCall is left without its functionResponse.
  void _trimHistory() {
    if (_history.length <= maxHistoryEntries) return;

    var cut = _history.length - maxHistoryEntries;
    while (cut < _history.length &&
        !_isUserMessage(_history[cut])) {
      cut++;
    }

    // If a single run made so many tool calls that no user
    // message falls inside the window, keep everything rather
    // than discarding the whole conversation.
    if (cut >= _history.length) return;

    _history.removeRange(0, cut);
  }

  Future<Map<String, dynamic>> _callLLM(
    List<Map<String, dynamic>> contents, {
    bool useTools = true,
    String? systemInstruction,
  }) async {
    final body = <String, dynamic>{
      'contents': contents,
    };

    if (systemInstruction != null) {
      body['systemInstruction'] = {
        'parts': [{'text': systemInstruction}],
      };
    }

    if (useTools && _tools.isNotEmpty) {
      final toolDefs = _tools.values
          .map((t) => {
                'name': t.name,
                'description': t.description,
                'parameters': t.parameters,
              })
          .toList();
      body['tools'] = [
        {'functionDeclarations': toolDefs},
      ];
    }

    final url = 'https://generativelanguage.googleapis.com'
        '/v1beta/models/$model:generateContent';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'API error ${response.statusCode}: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
