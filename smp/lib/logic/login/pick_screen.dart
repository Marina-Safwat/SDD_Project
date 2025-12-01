import 'package:flutter/material.dart';
import 'package:smp/logic/login/auth_service.dart';
import 'package:smp/screens/mood_screen/mood_screen.dart';
import 'package:smp/screens/tabs_screen.dart';
import 'package:smp/screens/login/loading_screen.dart';
import 'package:smp/screens/login/login_screen.dart';

class PickScreen extends StatelessWidget {
  const PickScreen({
    super.key,
    this.pageIfNotConnected,
  });

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthService>(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;

            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const LoadingScreen();
            } else if (snapshot.hasData) {
              widget = const MoodScreen();
            } else {
              widget = /* pageIfNotConnected ??*/ const LoginScreen();
            }

            return widget;
          },
        );
      },
    );
  }
}
