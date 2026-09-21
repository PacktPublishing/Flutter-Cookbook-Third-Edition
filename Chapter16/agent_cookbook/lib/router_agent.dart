import 'dart:convert';
import 'package:http/http.dart' as http;
import 'agent_runner.dart';
import 'specialist.dart';

class Subtask {
  final String id;
  final String specialist;
  final String task;
  final List<String> dependsOn;

  const Subtask({
    required this.id,
    required this.specialist,
    required this.task,
    this.dependsOn = const [],
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      specialist: json['specialist'] as String,
      task: json['task'] as String,
      dependsOn:
          (json['depends_on'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class RouterAgent {
  final String apiKey;
  final String model;
  final List<Specialist> specialists;

  RouterAgent({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
    required this.specialists,
  });

  Future<String> route(String userMessage) async {
    // Ask the LLM to split the request into subtasks.
    final plan = await _planSubtasks(userMessage);
    if (plan.isEmpty) {
      return 'Sorry, this request could not be handled '
          'by any of the available specialists.';
    }

    final results = <String, String>{};
    final pending = [...plan];

    // Run subtasks in rounds: each round runs every subtask
    // whose dependencies have already produced a result.
    while (pending.isNotEmpty) {
      final ready = pending
          .where((s) => s.dependsOn.every(results.containsKey))
          .toList();

      // Nothing can run: the plan has a cycle or a dangling id.
      if (ready.isEmpty) {
        final ids = pending.map((s) => s.id).join(', ');
        throw AgentException(
          'Could not resolve dependencies for subtasks: $ids',
        );
      }

      final entries = await Future.wait(
        ready.map((subtask) async {
          final specialist = specialists.firstWhere(
            (s) => s.name == subtask.specialist,
            orElse: () => specialists.first,
          );
          final prompt = _promptFor(subtask, results);
          return MapEntry(
            subtask.id,
            await specialist.handle(prompt),
          );
        }),
      );

      results.addEntries(entries);
      final done = ready.map((s) => s.id).toSet();
      pending.removeWhere((s) => done.contains(s.id));
    }

    // If only one subtask, return directly.
    if (results.length == 1) {
      return results.values.first;
    }

    // Combine results from multiple subtasks.
    return _combine(userMessage, plan, results);
  }

  Future<List<Subtask>> _planSubtasks(String userMessage) async {
    final descriptions = specialists
        .map((s) => '- ${s.name}: ${s.description}')
        .join('\n');

    final prompt =
        'Given these available specialists:\n'
        '$descriptions\n\n'
        'Split the request below into subtasks, each '
        'handled by one specialist and given a short '
        'unique id.\n\n'
        'Each task must be self-contained: the specialist '
        'sees only its own task, not the original request.\n'
        'If a task needs the result of another task, put '
        'that task\'s id in depends_on and refer to the '
        'value in words (e.g. "multiply the temperature '
        'above by 3").\n'
        'Use depends_on only when the task genuinely '
        'cannot be done without the earlier result.\n\n'
        'Request: $userMessage';

    final response = await _callLLM(
      prompt,
      responseSchema: {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'id': {'type': 'STRING'},
            'specialist': {
              'type': 'STRING',
              'enum': specialists.map((s) => s.name).toList(),
            },
            'task': {'type': 'STRING'},
            'depends_on': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
          },
          'required': ['id', 'specialist', 'task'],
        },
      },
    );

    final text = partsOrThrow(response)
        .map((p) => p['text'])
        .whereType<String>()
        .join('');
    final list = jsonDecode(text) as List;
    return list
        .map((e) => Subtask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _promptFor(Subtask subtask, Map<String, String> results) {
    if (subtask.dependsOn.isEmpty) {
      return subtask.task;
    }

    final context = subtask.dependsOn
        .map((id) => '- $id: ${results[id]}')
        .join('\n');
    return 'Results from earlier steps:\n$context\n\n'
        'Task: ${subtask.task}';
  }

  Future<String> _combine(
    String userMessage,
    List<Subtask> plan,
    Map<String, String> results,
  ) async {
    final transcript = plan
        .map((s) => '${s.id} (${s.specialist}): ${s.task}\n'
            'Result: ${results[s.id]}')
        .join('\n\n');

    final prompt =
        'The user asked: $userMessage\n\n'
        'The request was split into these steps:\n\n'
        '$transcript\n\n'
        'Combine these results into a single, coherent '
        'response for the user. Use only the values in the '
        'results above and do not invent values. Do not '
        'attach a unit to a number unless its result '
        'states that unit.';

    final response = await _callLLM(prompt);
    final text = partsOrThrow(response)
        .map((p) => p['text'])
        .whereType<String>()
        .join('\n');
    return text;
  }

  Future<Map<String, dynamic>> _callLLM(
    String prompt, {
    Map<String, dynamic>? responseSchema,
  }) async {
    final url =
        'https://generativelanguage.googleapis.com'
        '/v1beta/models/$model:generateContent';

    final body = <String, dynamic>{
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    };

    if (responseSchema != null) {
      body['generationConfig'] = {
        'responseMimeType': 'application/json',
        'responseSchema': responseSchema,
      };
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
