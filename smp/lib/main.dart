import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smp/firebase_options.dart';
import 'package:smp/screens/home_screen/mood_home_screen.dart';
import 'package:smp/screens/login/login_screen.dart';
import 'package:smp/screens/player_screen/player_screen.dart';
import 'package:smp/screens/tabs_screen.dart';
import 'package:smp/data/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), //
    ),
  );
}
