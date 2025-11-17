import 'package:flutter/material.dart';
import 'package:smp/screens/app.dart';
import 'package:smp/screens/login/login_screen.dart';
import 'package:smp/screens/mood_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginScreen(),
      home: MyApp(),
    ),
  );
}
