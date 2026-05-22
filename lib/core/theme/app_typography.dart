import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// FF Shamel → Tajawal; GE SS Two → Cairo (bold headings).
abstract final class AppTypography {
  static String get arabicFamily => GoogleFonts.tajawal().fontFamily!;
  static String get headingFamily => GoogleFonts.cairo().fontFamily!;

  static TextTheme textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final muted = brightness == Brightness.light ? AppColors.textMuted : AppColors.textMutedDark;

    final arabic = GoogleFonts.tajawalTextTheme();
    final headings = GoogleFonts.cairoTextTheme();

    return arabic.copyWith(
      displaySmall: headings.displaySmall?.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: color, height: 1.2),
      headlineMedium: headings.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: color, height: 1.25),
      headlineSmall: headings.headlineSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: color, height: 1.3),
      titleLarge: arabic.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: color),
      titleMedium: arabic.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: color),
      titleSmall: arabic.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      bodyLarge: arabic.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: color, height: 1.45),
      bodyMedium: arabic.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: muted, height: 1.4),
      bodySmall: arabic.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: muted, height: 1.35),
      labelLarge: arabic.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
      labelMedium: arabic.labelMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: muted),
      labelSmall: arabic.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: muted),
    );
  }

  static TextStyle shamelBold({double size = 14, Color? color}) => GoogleFonts.tajawal(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle shamelBook({double size = 10, Color? color}) => GoogleFonts.tajawal(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle geBold({double size = 14, Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );
}
