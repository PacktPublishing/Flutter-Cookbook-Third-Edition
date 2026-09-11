import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth.dart';
import '../router/routes.dart';

class LoginScreen extends StatelessWidget {
  final String? from;
  const LoginScreen({super.key, this.from});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authState.value = true;
            context.go(from ?? AppRoutes.home);
          },
          child: const Text('Sign In'),
        ),
      ),
    );
  }
}
