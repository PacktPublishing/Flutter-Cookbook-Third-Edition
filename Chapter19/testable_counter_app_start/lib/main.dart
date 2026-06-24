import 'package:flutter/material.dart';
import 'counter_screen.dart';

void main() => runApp(const CounterApp());

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const CounterScreen(),
    );
  }
}
