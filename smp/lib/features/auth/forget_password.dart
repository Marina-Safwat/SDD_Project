import 'package:flutter/material.dart';
import 'package:smp/features/auth/reset_password.dart';

/// A small text button used on login screens to navigate to the
/// Reset Password screen.
///
/// Designed to be placed at the right side of a column.
class ForgetPassword extends StatelessWidget {
  const ForgetPassword({
    super.key,
    this.alignment = Alignment.centerRight,
  });

  /// Optional alignment override (default: right-aligned).
  final Alignment alignment;

  void _goToResetPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ResetPassword(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TextButton(
        onPressed: () => _goToResetPassword(context),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
