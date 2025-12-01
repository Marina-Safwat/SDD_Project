import 'package:flutter/material.dart';

import 'package:smp/features/auth/auth_service.dart';
import 'package:smp/features/auth/login_screen.dart';
import 'package:smp/features/auth/loading_screen.dart';
import 'package:smp/features/mood/mood_screen.dart';

/// A simple auth gate that decides which screen to show based on
/// the current Firebase authentication state.
///
/// - While checking auth: shows [LoadingScreen].
/// - If a user is signed in: shows [MoodScreen].
/// - If no user: shows [LoginScreen] or [pageIfNotConnected] if provided.
class PickScreen extends StatelessWidget {
  const PickScreen({
    super.key,
    this.pageIfNotConnected,
  });

  /// Optional override screen if the user is not authenticated.
  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthService>(
      valueListenable: authService,
      builder: (context, auth, child) {
        return StreamBuilder(
          stream: auth.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (snapshot.hasData) {
              // User is authenticated
              return const MoodScreen();
            }

            // User is not authenticated
            return pageIfNotConnected ?? const LoginScreen();
          },
        );
      },
    );
  }
}
