import 'package:flutter/material.dart';

/// Orange left panel with a concave inner edge (waist) toward the content area.
class ProfileSidebarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.34)
      ..quadraticBezierTo(w * 0.58, h * 0.5, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
