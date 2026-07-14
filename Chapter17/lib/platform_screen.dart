import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

const isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

class PlatformScreen extends StatelessWidget {
  const PlatformScreen({super.key});

  Future<void> openSecondWindow() async {
    final window = await WindowController.create(
      const WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: 'second_window',
      ),
    );

    await window.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platforms')),
      body: Column(
        children: [
          Center(
            child: Text(
              'Running on ${getPlatformName()}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ElevatedButton( onPressed: openSecondWindow, child: const Text('Open second window'), ),
        ],
      ),
    );
  }

  String getPlatformName() {
    if (kIsWeb) return isWasm ? 'Web (WASM)' : 'Web (JS)';

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      default:
        return 'Unknown platform';
    }
  }
}
