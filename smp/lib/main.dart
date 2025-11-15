import 'package:flutter/material.dart';
import 'package:smp/screens/app.dart';
import 'package:smp/screens/login/login_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginScreen(),
      home: MyApp(),
    ),
  );
}
