import 'package:flutter/material.dart';

/// A reusable widget that displays the app logo or any image
/// with consistent sizing across authentication screens.
///
/// - Defaults to 240x240
/// - Allows customizing width, height, and fit if needed.
/// - Provides a graceful fallback if the image asset fails to load.
class LogoWidget extends StatelessWidget {
  const LogoWidget(
    this.imageName, {
    super.key,
    this.width = 240,
    this.height = 240,
    this.fit = BoxFit.fitWidth,
  });

  final String imageName;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageName,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white70,
        size: 50,
      ),
    );
  }
}
