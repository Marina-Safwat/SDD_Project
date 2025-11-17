import 'package:flutter/material.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/screens/login/signup_screen.dart';

class SignupGoogle extends StatelessWidget {
  const SignupGoogle({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await authService.value.signInWithGoogle();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignupScreen(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/google.png",
            height: 20,
            width: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            "Login with Gmail",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
