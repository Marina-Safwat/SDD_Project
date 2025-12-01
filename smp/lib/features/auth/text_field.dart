import 'package:flutter/material.dart';

/// A reusable text field widget used across the login & signup screens.
///
/// Improvements:
/// - Supports password or normal text.
/// - Allows optional hint text.
/// - Allows custom keyboardType, inputAction, and onChanged callbacks.
/// - Keeps a consistent design with gradient backgrounds.
/// - Fully customizable while maintaining backward compatibility.
class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.controller,
    this.isPasswordType = false,
    this.hintText,
    this.keyboardType,
    this.onChanged,
    this.textInputAction,
  });

  /// Label/title shown inside the field.
  final String text;

  /// Icon displayed at the start of the text field.
  final IconData icon;

  /// Whether the field hides text (password mode).
  final bool isPasswordType;

  /// Controller holding the text input.
  final TextEditingController controller;

  /// Optional hint text.
  final String? hintText;

  /// Optional keyboard type override.
  final TextInputType? keyboardType;

  /// Optional callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Optional keyboard action (next/done).
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType = keyboardType ??
        (isPasswordType
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress);

    return TextField(
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: Colors.white,
      textInputAction: textInputAction,
      keyboardType: effectiveKeyboardType,
      style: TextStyle(color: Colors.white.withOpacity(0.9)),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        labelText: text,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        hintStyle: TextStyle(color: Colors.white70.withOpacity(0.7)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
