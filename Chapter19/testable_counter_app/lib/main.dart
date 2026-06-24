import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'counter_screen.dart';
import 'counter_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final storage = FileCounterStorage(File('${dir.path}/counter.json'));
  runApp(CounterApp(storage: storage));
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key, required this.storage});

  final CounterStorage storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: CounterScreen(storage: storage),
    );
  }
}
