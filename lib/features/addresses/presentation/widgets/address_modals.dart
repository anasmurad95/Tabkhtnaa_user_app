import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

Future<void> showOrderSuccessModal(BuildContext context, {VoidCallback? onContactChef}) {
  return showDialog(
    context: context,
    builder: (ctx) => _FigmaModal(
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      title: ctx.tr('order_success', fallback: 'تم الطلب بنجاح'),
      message: ctx.tr('order_success_hint', fallback: 'يمكنك التواصل مع الشيف لمتابعة طلبك'),
      primaryLabel: ctx.tr('contact_chef', fallback: 'تواصل مع الشيف'),
      onPrimary: () {
        Navigator.pop(ctx);
        onContactChef?.call();
      },
      secondaryLabel: ctx.tr('close', fallback: 'إغلاق'),
      onSecondary: () => Navigator.pop(ctx),
    ),
  );
}

Future<void> showOrderFailureModal(BuildContext context, {String? message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _FigmaModal(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      title: ctx.tr('order_failed', fallback: 'فشل الطلب'),
      message: message ?? ctx.tr('order_failed_hint', fallback: 'تعذر إتمام الطلب، حاول مجدداً'),
      primaryLabel: ctx.tr('retry', fallback: 'إعادة المحاولة'),
      onPrimary: () => Navigator.pop(ctx),
    ),
  );
}

Future<bool> showDeleteAddressConfirm(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _FigmaModal(
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      title: ctx.tr('delete_address', fallback: 'حذف العنوان؟'),
      message: ctx.tr('delete_address_hint', fallback: 'هل أنت متأكد من حذف هذا العنوان؟'),
      primaryLabel: ctx.tr('delete', fallback: 'حذف'),
      onPrimary: () => Navigator.pop(ctx, true),
      secondaryLabel: ctx.tr('cancel', fallback: 'إلغاء'),
      onSecondary: () => Navigator.pop(ctx, false),
    ),
  );
  return result ?? false;
}

Future<void> showChefAddressMapModal(
  BuildContext context, {
  required String chefName,
  required String address,
  double? lat,
  double? lng,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => _FigmaModal(
      icon: Icons.map_outlined,
      iconColor: AppColors.primary,
      title: chefName,
      message: address,
      subtitle: lat != null && lng != null ? '$lat, $lng' : null,
      primaryLabel: ctx.tr('close', fallback: 'إغلاق'),
      onPrimary: () => Navigator.pop(ctx),
    ),
  );
}

class _FigmaModal extends StatelessWidget {
  const _FigmaModal({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: iconColor),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: AppTypography.shamelBold(size: 14)),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: AppTypography.shamelBook(size: 10, color: AppColors.textHint)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(onPressed: onPrimary, child: Text(primaryLabel)),
              ),
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 8),
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
