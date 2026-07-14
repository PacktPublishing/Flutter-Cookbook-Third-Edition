import 'dart:io';

import 'package:flutter/material.dart';
import 'notes_screen.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'platform_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final windowController = await WindowController.fromCurrentEngine();
  final arguments = windowController.arguments;

  if (arguments == 'second_window') {
    runApp(SecondWindowApp(message: arguments));
  } else {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(900, 600),
      center: true,
      title: 'Flutter Desktop App',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(const MainApp());
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    setupTray();
  }

  Future<void> setupTray() async {
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/tray_icon.ico' : 'assets/tray_icon.png',
    );

    await trayManager.setToolTip('Flutter Desktop App');

    final menu = Menu(
      items: [
        MenuItem(key: 'show', label: 'Show'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show') {
      windowManager.show();
      windowManager.focus();
    }

    if (menuItem.key == 'exit') {
      trayManager.destroy();
      windowManager.destroy();
    }
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PlatformScreen());
  }
}

class SecondWindowApp extends StatelessWidget {
  const SecondWindowApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Window',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Second Window')),
        body: Center(
          child: Text(
            'Hello from another desktop window',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
