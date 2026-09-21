// ignore_for_file: avoid_print

import 'dart:io';
import 'package:agent_cookbook/agent_runner.dart';
import 'package:agent_cookbook/weather_tool.dart';

void main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_API_KEY.');
    return;
  }

  final agent = AgentRunner(apiKey: apiKey)
    ..registerTool(WeatherTool());

  // One request that needs a tool call per city.
  final response = await agent.run(
    'What is the weather like in London right now, '
    'and how does it compare to Madrid?',
  );

  print(response);
}
