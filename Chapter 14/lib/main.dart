import 'package:flutter/material.dart';

import 'ml_kit_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MLKitScreen(),
      ),
    );
  }
}
