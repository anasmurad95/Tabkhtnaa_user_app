import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../../features/localization/presentation/extensions/translation_context.dart';

enum PermissionPromptKind { photos, location }

/// Figma permission modal — dark overlay, white card, orange close outside top-right.
Future<bool?> showPermissionPromptDialog(
  BuildContext context, {
  required PermissionPromptKind kind,
  VoidCallback? onLanguageTap,
}) {
  final isPhotos = kind == PermissionPromptKind.photos;
  final title = isPhotos
      ? context.tr(
          'permission_photos_title',
          fallback: 'هل تريد إعطاء التطبيق صلاحية الوصول الى الصور؟',
        )
      : context.tr(
          'permission_location_title',
          fallback: 'هل تريد لتطبيق طبختنا الوصول الى الموقع الجغرافي الخاص بك؟',
        );

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xFF2B2B2B),
    builder: (ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPhotos ? Icons.photo_library_outlined : Icons.location_on_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.shamelBold(size: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23.5),
                                ),
                              ),
                              child: Text(
                                context.tr('deny', fallback: 'رفض'),
                                style: AppTypography.shamelBold(size: 14, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                context.tr('allow', fallback: 'سماح'),
                                style: AppTypography.shamelBold(size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: onLanguageTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('choose_language', fallback: 'اختيار اللغة'),
                              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Navigator.pop(ctx, false),
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
