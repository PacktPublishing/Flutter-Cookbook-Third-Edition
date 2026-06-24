import 'package:flutter/material.dart';
import 'counter.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final Counter _counter = Counter();

  void _increment() {
    setState(() => _counter.increment());
  }

  void _decrement() {
    try {
      setState(() => _counter.decrement());
    } on StateError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Counter can't go below zero")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _counter.isEven ? 'Even' : 'Odd';
    final labelColor = _counter.isEven ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _counter.reset()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_counter.value}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: labelColor, fontSize: 20)),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: _decrement,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: _increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
