import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pagination for the 3-step splash/onboarding flow (Figma pill + dots).
class SplashStepDots extends StatelessWidget {
  const SplashStepDots({super.key, required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
        if (i == active) {
          return Container(
            width: 29,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        );
        }),
      ),
    );
  }
}
