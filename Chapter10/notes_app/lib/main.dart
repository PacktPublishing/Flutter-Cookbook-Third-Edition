import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'notes_get.dart';

void main() {
  Get.put(NotesController());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetX Notes',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
