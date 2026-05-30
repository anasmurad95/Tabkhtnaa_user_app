import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Three-step indicator for password reset (Figma: active orange pill, inactive grey dots).
class PasswordResetStepDots extends StatelessWidget {
  const PasswordResetStepDots({super.key, required this.active});

  /// 0, 1, or 2
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        if (i == active) {
          return Container(
            width: 29,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: AppColors.indicatorInactive,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
