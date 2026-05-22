import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma 7. map (0:3332, 0:3212, 0:3010)
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaPageScaffold(
      title: context.tr('nav_map', fallback: 'الخريطة'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.25,
            child: Image.asset(FigmaAssets.splashBgFood, fit: BoxFit.cover),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                    child: Image.asset(FigmaAssets.globeWhite, width: 48, height: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('map_coming_soon', fallback: 'خريطة الطهاة والوجبات'),
                    textAlign: TextAlign.center,
                    style: AppTypography.geBold(size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('map_hint', fallback: 'سيتم عرض الطهاة على الخريطة عند تفعيل الموقع'),
                    textAlign: TextAlign.center,
                    style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
