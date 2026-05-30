import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../localization/presentation/providers/translation_provider.dart';

/// Post-language bootstrap splash — Figma orange brand loading.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final loadingLabel = context.watch<TranslationProvider>().tr('loading', fallback: 'جاري التحميل…');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            FigmaAssetImage(FigmaAssets.splashBgFood, fit: BoxFit.cover),
            Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FigmaAssetImage(FigmaAssets.splashLogoMain, width: 120, height: 114, fit: BoxFit.contain, color: Colors.white),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loadingLabel,
                    style: AppTypography.shamelBold(size: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
