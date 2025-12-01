import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/data/data.dart';
import 'package:smp/features/auth/pick_screen.dart';
import 'package:smp/models/user_profile.dart';
import 'package:smp/features/auth/auth_service.dart';
import 'package:smp/features/auth/button.dart';
import 'package:smp/features/auth/signup_google.dart';
import 'package:smp/features/auth/text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  // final TextEditingController _userNameTextController = TextEditingController();

  String _errorMessage = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    // _userNameTextController.dispose();
    super.dispose();
  }

  Future<void> _signUp(BuildContext context) async {
    final email = _emailTextController.text.trim();
    final password = _passwordTextController.text.trim();
    // final username = _userNameTextController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password should be at least 6 characters.';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _isSubmitting = true;
    });

    try {
      await authService.value.createAccount(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Optional: update display name later using username
        // await authService.value.updateUsername(username: username);

        users[email] = UserProfile.fromFirebaseUser(user);
      }

      if (!mounted) return;

      // After successful signup, go to PickScreen and remove Signup from back stack.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PickScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An unknown error occurred.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF05A89),
              Color(0xFF7A36C4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                /* If you want username in the future:
                TextFieldWidget(
                  text: 'Enter Username',
                  icon: Icons.person_outline,
                  isPasswordType: false,
                  controller: _userNameTextController,
                ),
                const SizedBox(height: 20),
                */
                TextFieldWidget(
                  text: 'Enter Your Email',
                  icon: Icons.email_outlined,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  text: 'Enter Password',
                  icon: Icons.lock_outline,
                  isPasswordType: true,
                  controller: _passwordTextController,
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                Button(
                  onTap: () => _signUp(context),
                  title: 'SIGN UP',
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 10),
                const SignupGoogle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
