import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget(this.imageName, {super.key});
  final String imageName;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageName,
      fit: BoxFit.fitWidth,
      width: 240,
      height: 240,
    );
  }
}
