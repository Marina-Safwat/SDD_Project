import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smp/firebase_options.dart';
import 'package:smp/screens/login/login_screen.dart';
import 'package:smp/screens/mood_screen/mood_screen.dart';
import 'package:smp/screens/tabs_screen.dart';
import 'package:smp/screens/test_spotify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFC34B7C),
      ),
      // home: const TestApiScreen(),
      home: const MoodScreen(),
    ),
  );
}
