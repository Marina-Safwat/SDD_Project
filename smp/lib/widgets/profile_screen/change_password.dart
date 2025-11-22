import 'package:flutter/material.dart';
import 'package:smp/screens/login/reset_password.dart';

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
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
    // return Container(
    //   width: MediaQuery.of(context).size.width,
    //   height: 35,
    //   alignment: Alignment.bottomRight,
    //   child: TextButton(
    //     child: const Text(
    //       "Forgot Password?",
    //       style: TextStyle(color: Colors.white70),
    //       textAlign: TextAlign.right,
    //     ),
    //     onPressed: () => Navigator.push(context,
    //         MaterialPageRoute(builder: (context) => const ResetPassword())),
    //   ),
    // );
  }
}
