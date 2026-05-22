import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma 0:4047 — notifications (no list API in API_FLUTTER.md; empty until backend wired)
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaPageScaffold(
      title: context.tr('notifications', fallback: 'الاشعارات'),
      onBack: () => Navigator.pop(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(FigmaAssets.profileNotification, width: 48, height: 48),
              const SizedBox(height: 16),
              Text(
                context.tr('no_notifications', fallback: 'لا توجد إشعارات حالياً'),
                textAlign: TextAlign.center,
                style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
