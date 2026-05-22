import 'package:flutter/material.dart';

/// Figma Food-Project-1 (Copy) — vf6Xx7NvM8GBGditNmCUqu
class AppColors {
  static const primary = Color(0xFFF57017);
  static const primaryDark = Color(0xFFF74A00);
  static const primaryGradientEnd = Color(0xFFF2871F);
  static const accent = Color(0xFFF48C2A);
  static const primaryLight = Color(0x26F48C2A);
  static const secondary = accent;
  static const backgroundLight = background;
  static const surfaceLight = surface;
  static const surfaceMuted = background;
  static const accentRed = Color(0xFFF45742);
  static const facebookBlue = Color(0xFF4065B4);

  static const background = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFC3C3C3);
  static const textPrimary = Color(0xFF171717);
  static const textMuted = Color(0xFF7C7F84);
  static const iconMuted = Color(0xFF80868B);
  static const textHint = Color(0xFFABABAB);
  static const indicatorInactive = Color(0xFFCACDD4);

  static const backgroundDark = Color(0xFF121418);
  static const surfaceDark = Color(0xFF1C1F26);
  static const textPrimaryDark = Color(0xFFF5F6FA);
  static const textMutedDark = Color(0xFF9AA0B2);
  static const borderDark = Color(0xFF2E3340);

  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);

  static const shadow = Color(0x1A171717);
  static const overlay = Color(0x80000000);

  static const splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryGradientEnd],
    stops: [0, 0.99372],
  );
}
