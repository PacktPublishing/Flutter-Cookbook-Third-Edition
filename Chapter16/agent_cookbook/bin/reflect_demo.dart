// ignore_for_file: avoid_print

import 'dart:io';
import 'package:agent_cookbook/agent_callbacks.dart';
import 'package:agent_cookbook/reflective_agent.dart';
import 'package:agent_cookbook/weather_tool.dart';

void main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_API_KEY.');
    return;
  }

  final agent = ReflectiveAgent(apiKey: apiKey)
    ..registerTool(WeatherTool());

  // Print each phase as it happens.
  final callbacks = AgentCallbacks(
    onPlan: (plan) => print('--- Plan ---\n$plan\n'),
    onToolCall: (name, args) => print('--- Tool call: $name $args'),
    onToolResult: (name, result) => print('--- Tool result: $result'),
    // A passing reflection is the final answer, printed below.
    // Only an incomplete one is feedback worth showing.
    onReflect: (text) {
      if (text.contains('[INCOMPLETE]')) {
        print('\n--- Reflection (incomplete) ---\n$text\n');
      }
    },
  );

  // Several tool calls, then a comparison the tool's data
  // can actually support (it returns temperature only).
  final response = await agent.run(
    'Compare the current temperature in Oslo, Lisbon and Tokyo, '
    'and say which is warmest and by how much.',
    callbacks: callbacks,
  );

  print('--- Final answer ---\n$response');
}
