import 'package:flutter/material.dart';

class CategoryTitle extends StatelessWidget {
  const CategoryTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black26,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
