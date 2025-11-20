import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smp/firebase_options.dart';
import 'package:smp/screens/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFC34B7C),
      ),
      home: LoginScreen(),
    ),
  );
}
