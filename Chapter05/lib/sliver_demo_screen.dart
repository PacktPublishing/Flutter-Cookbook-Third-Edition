import 'package:flutter/material.dart';

class SliverDemoScreen extends StatelessWidget {
  const SliverDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Profile'),
            expandedHeight: 220,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Item #$index'),
              ),
              childCount: 25,
            ),
          ),
        ],
      ),
    );
  }
}
