import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/data/data.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/logic/login/pick_screen.dart';
import 'package:smp/models/user_profile.dart';
//import 'package:ra_interview/screens/login/home_screen.dart';
import 'package:smp/widgets/login/button.dart';
import 'package:smp/widgets/login/signup_google.dart';
import 'package:smp/widgets/login/text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  //final TextEditingController _userNameTextController = TextEditingController();
  String errorMessage = "";

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  void signUp(BuildContext context) async {
    try {
      await authService.value.createAccount(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      users[_emailTextController.text] =
          UserProfile.fromFirebaseUser(FirebaseAuth.instance.currentUser!);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const PickScreen()));
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
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                /*TextFieldWidget(
                  text: "Enter Username",
                  icon: Icons.person_outline,
                  isPasswordType: false,
                  controller: _userNameTextController,
                ),
                const SizedBox(
                  height: 20,
                ),*/
                TextFieldWidget(
                  text: "Enter Your Email",
                  icon: Icons.person_outline,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  text: "Enter Password",
                  icon: Icons.lock_outline,
                  isPasswordType: true,
                  controller: _passwordTextController,
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
                  title: "SIGN UP",
                ),
                const SignupGoogle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
