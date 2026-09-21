import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_config.dart';
import 'flavor_banner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final flavor = appFlavor ?? 'none';
    final title = flavor == 'none'
        ? 'MyApp'
        : 'MyApp ${flavor[0].toUpperCase()}${flavor.substring(1)}';
    final mode = kReleaseMode
        ? 'release'
        : kProfileMode
            ? 'profile'
            : 'debug';

    return FlavorBanner(
      child: MaterialApp(
        debugShowCheckedModeBanner: AppConfig.showDebugBanner,
        home: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _row('Flavor', flavor),
                _row('Build mode', mode),
                _row('API base URL', AppConfig.apiBaseUrl),
                _row('Log level', AppConfig.logLevel),
                _row('Debug banner', AppConfig.showDebugBanner.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text('$k:  $v', style: const TextStyle(fontSize: 18)),
      );
}
