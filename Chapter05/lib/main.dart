import 'package:flutter/material.dart';
import 'e_commerce_screen_after.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter for Beginners',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 10,
          titleTextStyle: TextStyle(
            fontFamily: 'LeckerliOne',
            fontSize: 24,
          ),
        ),
      ),
      home: const ECommerceScreen(),
    );
  }
}
