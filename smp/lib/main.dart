import 'package:flutter/material.dart';
import 'package:smp/screens/app.dart';
// import 'package:smp/screens/home.dart';

void main() {
  runApp(const Smp());
}

class Smp extends StatelessWidget {
  const Smp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
  }
}
