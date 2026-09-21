// ignore_for_file: avoid_print

import 'dart:io';
import 'package:agent_cookbook/calculator_tool.dart';
import 'package:agent_cookbook/router_agent.dart';
import 'package:agent_cookbook/specialist.dart';
import 'package:agent_cookbook/weather_tool.dart';

void main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_API_KEY.');
    return;
  }

  final router = RouterAgent(
    apiKey: apiKey,
    specialists: [
      Specialist(
        name: 'weather',
        description: 'Answers questions about '
            'current weather conditions in any city.',
        apiKey: apiKey,
        tools: [WeatherTool()],
      ),
      Specialist(
        name: 'math',
        description: 'Evaluates math expressions '
            'and answers calculation questions.',
        apiKey: apiKey,
        tools: [CalculatorTool()],
      ),
    ],
  );

  // A mixed request that needs both specialists.
  final response = await router.route(
    'What is the current temperature in Paris, '
    'and how many degrees warmer or cooler is that '
    'than 20°C?',
  );

  print(response);
}
