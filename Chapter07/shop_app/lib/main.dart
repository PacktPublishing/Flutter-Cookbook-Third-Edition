import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router/router.dart';

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shop App',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      routerConfig: appRouter,
    );
  }
}
