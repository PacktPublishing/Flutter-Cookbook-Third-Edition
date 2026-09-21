import 'dart:convert';
import 'package:http/http.dart' as http;
import 'agent_callbacks.dart';
import 'agent_runner.dart';
import 'tool.dart';

/// Wraps an [AgentRunner] with plan and reflect phases: plan the
/// request, act on it with the runner's agentic loop, then review
/// the result and re-plan if it is incomplete.
class ReflectiveAgent {
  ReflectiveAgent({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
    this.maxAttempts = 3,
  }) : _runner = AgentRunner(apiKey: apiKey, model: model);

  final String apiKey;
  final String model;
  final int maxAttempts;
  final AgentRunner _runner;

  void registerTool(Tool tool) => _runner.registerTool(tool);
  void reset() => _runner.reset();

  Future<String> run(
    String userMessage, {
    AgentCallbacks? callbacks,
  }) async {
    // The runner reports tool activity, but not completion:
    // onComplete fires once, from here, after reflection.
    final actCallbacks = AgentCallbacks(
      onToolCall: callbacks?.onToolCall,
      onToolResult: callbacks?.onToolResult,
    );

    String? feedback;
    var finalText = 'Could not complete the request.';

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      // Phase 1: Plan
      final plan = await _plan(userMessage, feedback);
      callbacks?.onPlan?.call(plan);

      // Phase 2: Act (agentic loop from Recipe 1)
      final result = await _runner.run(
        userMessage,
        callbacks: actCallbacks,
        systemInstruction: 'Answer the latest user request by '
            'following the plan.\n\nPlan:\n$plan',
      );

      // Phase 3: Reflect
      final reflection = await _reflect(userMessage, result);
      callbacks?.onReflect?.call(reflection);

      // If the reflection is complete, it is the answer.
      if (!reflection.contains('[INCOMPLETE]')) {
        finalText = reflection;
        break;
      }

      // Otherwise, use the feedback to re-plan.
      feedback = reflection;
    }

    callbacks?.onComplete?.call(finalText);
    return finalText;
  }

  Future<String> _plan(
    String userMessage,
    String? previousFeedback,
  ) async {
    final prompt = StringBuffer()
      ..writeln('Break this request into concrete')
      ..writeln('steps. List each step briefly.')
      ..writeln()
      ..writeln('Request: $userMessage');

    if (previousFeedback != null) {
      prompt
        ..writeln()
        ..writeln('A previous attempt was incomplete.')
        ..writeln('Feedback: $previousFeedback')
        ..writeln('Revise the plan to address this.');
    }

    final contents = [
      {
        'role': 'user',
        'parts': [{'text': prompt.toString()}],
      },
    ];

    final response = await _callLLM(contents);
    final parts = partsOrThrow(response);
    return parts
        .map((p) => p['text'])
        .whereType<String>()
        .join('\n');
  }

  Future<String> _reflect(
    String userMessage,
    String result,
  ) async {
    final contents = [
      {
        'role': 'user',
        'parts': [
          {
            'text': 'The user asked: $userMessage\n\n'
                'Here is the result:\n$result\n\n'
                'Review this result. If it fully '
                'answers the request, provide the '
                'final polished response. If something '
                'is missing or incorrect, start your '
                'response with [INCOMPLETE] and explain '
                'what needs to be fixed.',
          }
        ],
      },
    ];

    final response = await _callLLM(contents);
    final parts = partsOrThrow(response);
    return parts
        .map((p) => p['text'])
        .whereType<String>()
        .join('\n');
  }

  /// Plain text generation for the plan and reflect phases,
  /// which never offer tools to the model.
  Future<Map<String, dynamic>> _callLLM(
    List<Map<String, dynamic>> contents,
  ) async {
    final url = 'https://generativelanguage.googleapis.com'
        '/v1beta/models/$model:generateContent';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({'contents': contents}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'API error ${response.statusCode}: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
