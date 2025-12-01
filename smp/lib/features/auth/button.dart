import 'package:flutter/material.dart';

/// Primary rounded button used on auth screens.
///
/// - Expands to the available width of its parent.
/// - Supports a disabled and loading state.
/// - Keeps a consistent style across the app.
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.onTap,
    required this.title,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final VoidCallback onTap;
  final String title;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canTap ? onTap : null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.white.withOpacity(0.6);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
