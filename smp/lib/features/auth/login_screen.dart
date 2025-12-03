import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/data/data.dart';
import 'package:smp/features/auth/pick_screen.dart';
import 'package:smp/features/auth/auth_service.dart';
import 'package:smp/models/user_profile.dart';
import 'package:smp/features/auth/button.dart';
import 'package:smp/features/auth/forget_password.dart';
import 'package:smp/features/auth/logo_widget.dart';
import 'package:smp/features/auth/signup_google.dart';
import 'package:smp/features/auth/signup_option.dart';
import 'package:smp/features/auth/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  String _errorMessage = '';

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailTextController.text; //.trim();
    final password = _passwordTextController.text; //.trim();
    print(email);
    print(password);

    // Basic validation before hitting Firebase.
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = '';
      });

      await authService.value.signIn(
        email: email,
        password: password,
      );
      print(email);

      final user = FirebaseAuth.instance.currentUser;
      //final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Store/update user profile in the in-memory map.
        users[email] = UserProfile.fromFirebaseUser(user);
      }

      // Navigate to the next screen and remove Login from the back stack.
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PickScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Login failed. Please try again.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
                const LogoWidget('assets/images/logo1.png'),
                const SizedBox(height: 30),
                TextFieldWidget(
                  text: 'Enter Your Email',
                  icon: Icons.person_outline,
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
                const SizedBox(height: 10),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                const ForgetPassword(),
                Button(
                  onTap: _signIn,
                  title: 'LOG IN',
                ),
                const SignupOption(),
                const SignupGoogle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
