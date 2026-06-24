import 'package:flutter/material.dart';
import 'counter.dart';

import 'counter_controller.dart';
import 'counter_storage.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key, required this.storage});

  final CounterStorage storage;

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late final CounterController _controller = CounterController(widget.storage);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    setState(() {});
  }

  Future<void> _increment() async {
    await _controller.increment();
    setState(() {});
  }

  Future<void> _decrement() async {
    try {
      await _controller.decrement();
      setState(() {});
    } on StateError {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Counter can't go below zero")));
    }
  }

  Future<void> _reset() async {
    await _controller.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final label = _controller.isEven ? 'Even' : 'Odd';
    final labelColor = _controller.isEven ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            onPressed: _reset,
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
              '${_controller.value}',
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
