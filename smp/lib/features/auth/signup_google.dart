import 'package:flutter/material.dart';
import 'package:smp/features/auth/auth_service.dart';
import 'package:smp/features/auth/pick_screen.dart';
import 'package:smp/features/auth/signup_screen.dart';

/// Button row used to sign in using Google authentication.
class SignupGoogle extends StatefulWidget {
  const SignupGoogle({super.key});

  @override
  State<SignupGoogle> createState() => _SignupGoogleState();
}

class _SignupGoogleState extends State<SignupGoogle> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final userCredential = await authService.value.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    // User canceled Google sign-in
    if (userCredential == null) return;

    final user = userCredential.user;

    // If the user has no display name, send them to sign-up to complete profile
    if (user?.displayName == null || (user?.displayName?.isEmpty ?? true)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignupScreen()),
      );
      return;
    }

    // If display name exists → go to main app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PickScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : () => _handleGoogleSignIn(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/google.png",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Login with Google",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
