import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/screens/login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String errorMessage = "";

  void logout() async {
    try {
      await authService.value.signOut();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "An unknown error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                child: const Text('Log Out')),
          ],
        ),
      ),
    );
  }
}
