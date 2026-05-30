import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Upward semi-ellipse at the top of the white bottom panel (Figma `splash_bottom_wave`).
///
/// ViewBox 676×292, ellipse rx=338 ry=146 — peak at top center, edges dip lower.
class SplashWaveClipper extends CustomClipper<Path> {
  const SplashWaveClipper({this.screenWidth});

  /// Screen width for arc math (use [MediaQuery.sizeOf] on wide web viewports).
  final double? screenWidth;

  /// Figma ellipse vertical radius / viewBox width.
  static const double waveDepthRatio = 146 / 676;

  static double waveDepthForWidth(double width) => width * waveDepthRatio;

  @override
  Path getClip(Size size) {
    final arcWidth = screenWidth ?? size.width;
    final waveDepth = waveDepthForWidth(arcWidth);
    final path = Path();
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, waveDepth),
      width: size.width,
      height: waveDepth * 2,
    );
    path.moveTo(0, waveDepth);
    // Clockwise sweep through the top half: peak at center y=0, sides at y=waveDepth.
    path.arcTo(oval, math.pi, math.pi, false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant SplashWaveClipper oldClipper) {
    return oldClipper.screenWidth != screenWidth;
  }
}

/// Orange tint over the splash food flat-lay (language screen header).
class SplashFoodHeaderBackground extends StatelessWidget {
  const SplashFoodHeaderBackground({
    super.key,
    this.overlayOpacity = 0.75,
    this.child,
  });

  /// Semi-transparent orange layer; food photo remains visible underneath.
  final double overlayOpacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          FigmaAssets.splashBgFood,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const ColoredBox(color: AppColors.primary),
        ),
        if (overlayOpacity > 0)
          ColoredBox(color: AppColors.primary.withValues(alpha: overlayOpacity)),
        ?child,
      ],
    );
  }
}
