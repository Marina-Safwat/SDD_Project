import 'package:flutter/material.dart';
import 'package:smp/features/auth/reset_password.dart';

/// A simple reusable widget for navigating to the "Reset Password" screen.
///
/// This appears inside the ProfileScreen.
/// No business logic is stored here — only navigation.
/// The ResetPassword screen handles all Firebase password logic.
///
/// Keeping this widget small and clean ensures better reusability and readability.
class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: const Text('Change Password'),
        
        /// On tap → navigate to ResetPassword page.
        /// No extra logic here, keeps the separation of concerns clear.
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResetPassword(),
            ),
          );
        },
      ),
    );
  }
}
