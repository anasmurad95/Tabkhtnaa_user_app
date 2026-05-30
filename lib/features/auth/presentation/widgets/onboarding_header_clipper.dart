import 'package:flutter/material.dart';

/// Curved bottom edge on the orange onboarding header (Figma Onboard 2).
class OnboardingHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.82);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.08,
      0,
      size.height * 0.82,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
