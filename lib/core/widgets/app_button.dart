import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.xs)],
              Text(label),
            ],
          );

    final minSize = expand ? const Size.fromHeight(52) : null;

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(minimumSize: minSize),
          child: child,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize,
            backgroundColor: AppColors.secondary,
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pillButton)),
          ),
          child: child,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: loading ? null : onPressed,
          child: child,
        );
    }
  }
}
