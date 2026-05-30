import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Padlock + orange code box (Figma reset password hero).
class PasswordResetIllustration extends StatelessWidget {
  const PasswordResetIllustration({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.55,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '****',
                style: AppTypography.shamelBold(size: 14, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Icon(
              Icons.lock_open_rounded,
              size: size * 0.72,
              color: const Color(0xFFFFC107),
            ),
          ),
        ],
      ),
    );
  }
}
