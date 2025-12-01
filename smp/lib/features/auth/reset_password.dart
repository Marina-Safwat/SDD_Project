import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:smp/features/auth/auth_service.dart';
import 'package:smp/features/auth/button.dart';
import 'package:smp/features/auth/text_field.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  String _errorMessage = '';
  String _infoMessage = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailTextController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
        _infoMessage = '';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _infoMessage = '';
      _isSubmitting = true;
    });

    try {
      await authService.value.resetPassword(email: email);

      setState(() {
        _infoMessage =
            'If an account exists for this email, a reset link has been sent.';
      });

      // Optionally pop the screen after a short delay or immediately.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Failed to send reset email.';
        _infoMessage = '';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _infoMessage = '';
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
          'Reset Password',
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
                TextFieldWidget(
                  text: 'Enter Your Email',
                  icon: Icons.person_outline,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_infoMessage.isNotEmpty)
                  Text(
                    _infoMessage,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                Button(
                  onTap: () => _resetPassword(context),
                  title: 'RESET PASSWORD',
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
