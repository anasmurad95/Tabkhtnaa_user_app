import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OtpCircles extends StatelessWidget {
  const OtpCircles({super.key, required this.filledCount});

  final int filledCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) {
        final filled = i < filledCount;
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : Colors.white,
            border: Border.all(
              color: filled ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key, required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (col) {
                final key = keys[row * 3 + col];
                return KeypadKey(label: key, onTap: () => onDigit(key));
              }),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72),
              KeypadKey(label: '0', onTap: () => onDigit('0')),
              KeypadKey(icon: Icons.backspace_outlined, onTap: onBackspace),
            ],
          ),
        ),
      ],
    );
  }
}

class KeypadKey extends StatelessWidget {
  const KeypadKey({super.key, this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.textPrimary, size: 22)
                : Text(
                    label ?? '',
                    style: AppTypography.shamelBold(size: 22, color: AppColors.textPrimary),
                  ),
          ),
        ),
      ),
    );
  }
}
