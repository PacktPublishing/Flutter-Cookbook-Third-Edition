import 'package:flutter/material.dart';
import './animated_list.dart';
import 'list_screen.dart';
import 'shape_animation.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ShapeAnimation(),
    );
  }
}
