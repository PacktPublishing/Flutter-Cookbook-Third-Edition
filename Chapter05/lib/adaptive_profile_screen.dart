import 'package:flutter/material.dart';

class AdaptiveProfileScreen extends StatelessWidget {
  const AdaptiveProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return const WideProfileLayout();
          }
          return const MobileProfileLayout();
        },
      ),
    );
  }
}

class MobileProfileLayout extends StatelessWidget {
  const MobileProfileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text('Mobile layout: single column'),
        ],
      ),
    );
  }
}

class WideProfileLayout extends StatelessWidget {
  const WideProfileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.green,
              child: const Text('Navigation / Summary'),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: Colors.yellow,
              child: const Text('Details pane'),
            ),
          ),
        ],
      ),
    );
  }
}
