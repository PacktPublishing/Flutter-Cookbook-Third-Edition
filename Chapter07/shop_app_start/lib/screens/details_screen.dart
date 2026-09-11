import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('📦', style: TextStyle(fontSize: 96))),
            const SizedBox(height: 24),
            Text(
              'Product Name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$0.00',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.green.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'Product description goes here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
