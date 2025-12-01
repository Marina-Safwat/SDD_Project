import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/firebase_options.dart';
import 'features/auth/login_screen.dart';

/// Entry point of the application.
///
/// - Ensures Flutter bindings are initialized.
/// - Initializes Firebase.
/// - Starts the root widget [MyApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// Root widget of the SMP application.
///
/// This is the place to define:
/// - App-wide theme
/// - Initial route / home screen
/// - (Later) routes and providers
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      // TODO: After implementing auth logic, we can decide whether to show
      // LoginScreen or TabsScreen based on the current user.
      home: const LoginScreen(),
    );
  }
}
