import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/logic/login/pick_screen.dart';
import 'package:smp/widgets/login/button.dart';
import 'package:smp/widgets/login/forget_password.dart';
import 'package:smp/widgets/login/logo_widget.dart';
import 'package:smp/widgets/login/signup_google.dart';
import 'package:smp/widgets/login/signup_option.dart';
import 'package:smp/widgets/login/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  String errorMessage = "";
  void signIn() async {
    try {
      await authService.value.signIn(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const PickScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'This is not working';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const LogoWidget('assets/images/logo1.png'),
                const SizedBox(
                  height: 30,
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
                TextFieldWidget(
                  text: "Enter Password",
                  icon: Icons.lock_outline,
                  isPasswordType: true,
                  controller: _passwordTextController,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const ForgetPassword(),
                Button(
                  onTap: () {
                    signIn();
                  },
                  title: "LOG IN",
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
