import 'package:books/stream_screen.dart';
import 'package:flutter/material.dart';
import 'future_screen.dart';
import 'geolocation_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: StreamScreen());
  }
}
