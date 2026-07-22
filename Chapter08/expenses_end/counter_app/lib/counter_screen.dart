import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int appCounter = 0;
  final secureStorage = FlutterSecureStorage();

  Future<void> readAndWriteSecureValue() async {
    final String? storedValue = await secureStorage.read(key: 'counterKey');
    final int current = int.tryParse(storedValue ?? '') ?? 0;
    final int updated = current + 1;
    await secureStorage.write(key: 'counterKey', value: updated.toString());

    setState(() {
      appCounter = updated;
    });
  }

  @override
  void initState() {
    super.initState();
    readAndWriteSecureValue();
  }

  Future<void> deleteSecureValue() async {
    await secureStorage.delete(key: 'counterKey');

    setState(() {
      appCounter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('You have opened the app $appCounter times.'),
            ElevatedButton(onPressed: () {
              deleteSecureValue(); 
            }, child: Text('Reset counter')),
          ],
        ),
      ),
    );
  }
}
