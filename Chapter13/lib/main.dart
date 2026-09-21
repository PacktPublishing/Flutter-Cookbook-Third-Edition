import 'package:firebase_demo/screens/happy_screen.dart';
// TEMPORARY (screenshot only) — revert with the home: change in MyApp.
import 'package:firebase_demo/screens/upload_file_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print("Notification: ${message.notification?.title} - ${message.notification?.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configure Crashlytics error handling
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    // Web client ID from Firebase console > Authentication > Sign-in method >
    // Google > Web SDK configuration. Ends in .apps.googleusercontent.com
    GoogleProvider(clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com'),
  ]);

  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission(
    provisional: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      // TEMPORARY (screenshot only) — revert to: home: const HappyScreen(),
      home: const UploadFileScreen(),
    );
  }
}
