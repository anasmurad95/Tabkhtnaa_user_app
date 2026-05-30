import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import 'password_reset_scaffold.dart';

Future<void> showRegisterContinueDialog(
  BuildContext context, {
  required VoidCallback onContinue,
  required VoidCallback onExit,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              ctx.tr('register_otp_success', fallback: 'تم تأكيد رقم الهاتف بنجاح'),
              textAlign: TextAlign.center,
              style: AppTypography.shamelBold(size: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            PasswordResetPrimaryButton(
              label: ctx.tr('complete_registration', fallback: 'اكمال عملية التسجيل'),
              onPressed: () {
                Navigator.pop(ctx);
                onContinue();
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onExit();
              },
              child: Text(
                ctx.tr('exit', fallback: 'الخروج'),
                style: AppTypography.shamelBold(size: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
