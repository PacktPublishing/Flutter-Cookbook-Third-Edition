import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final int index;
  final String drink;
  const DetailScreen({super.key, required this.index, required this.drink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Screen')),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.amber),
              child: Hero(
                tag: 'cup$index',
                child: const Icon(Icons.free_breakfast, size: 96),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: Text(
              drink,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ],
      ),
    );
  }
}
