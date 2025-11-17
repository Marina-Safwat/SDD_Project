import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/widgets/login/button.dart';
import 'package:smp/widgets/login/text_field.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  String errorMessage = "";

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  void signUp(BuildContext context) async {
    try {
      await authService.value.resetPassword(
        email: _emailTextController.text,
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "An unknown error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 109, 13, 142),
              Colors.deepPurple,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  text: "Enter Your Email",
                  icon: Icons.person_outline,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(
                  height: 20,
                ),
                Button(
                  onTap: () {
                    signUp(context);
                  },
                  title: "RESET PASSWORD",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
