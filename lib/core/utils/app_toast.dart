import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Consistent floating toast notifications (SnackBar) across the app.
class AppToast {
  AppToast._();

  static void success(BuildContext context, String message) =>
      _show(context, message, _ToastKind.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _ToastKind.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, _ToastKind.info);

  static void _show(BuildContext context, String message, _ToastKind kind) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final (Color background, IconData icon) = switch (kind) {
      _ToastKind.success => (AppColors.success, Icons.check_circle_outline),
      _ToastKind.error => (AppColors.error, Icons.error_outline),
      _ToastKind.info => (AppColors.textPrimary, Icons.info_outline),
    };

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.shamelBook(size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ToastKind { success, error, info }
