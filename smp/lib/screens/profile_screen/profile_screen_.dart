import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/screens/login/login_screen.dart';

class ProfileScreen_ extends StatefulWidget {
  const ProfileScreen_({super.key});

  @override
  State<ProfileScreen_> createState() => _ProfileScreen_State();
}

class _ProfileScreen_State extends State<ProfileScreen_> {
  String errorMessage = "";

  void logout() async {
    try {
      //await authService.value.signOut();
      await authService.value.googleSignOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "An unknown error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text("${FirebaseAuth.instance.currentUser!.displayName}"),
            Text("${FirebaseAuth.instance.currentUser!.email}"),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                logout();
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
