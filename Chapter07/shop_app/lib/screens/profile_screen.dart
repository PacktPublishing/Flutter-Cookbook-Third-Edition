import 'package:flutter/material.dart';
import '../data/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
            const SizedBox(height: 16),
            const Text('Guest User', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            const Text('guest@example.com'),
            ElevatedButton(
              onPressed: () {
                authState.value = false;
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
