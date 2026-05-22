import 'package:flutter/material.dart';

/// Upward curve at the top of the white bottom panel (splash language screen).
class SplashWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.14);
    path.quadraticBezierTo(
      size.width * 0.5,
      -size.height * 0.06,
      size.width,
      size.height * 0.14,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
