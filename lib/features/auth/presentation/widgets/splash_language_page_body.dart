import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import 'splash_step_dots.dart';
import 'splash_wave_clipper.dart';

/// Shared language-selection splash layout (Figma 0:5305).
class SplashLanguagePageBody extends StatelessWidget {
  const SplashLanguagePageBody({super.key, required this.onPickLanguage});

  final VoidCallback onPickLanguage;

  @override
  Widget build(BuildContext context) {
    final label = context.watch<TranslationProvider>().tr('choose_language', fallback: 'اختيار اللغة');

    final screenWidth = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final topHeight = h * 0.75;
        final waveDepth = SplashWaveClipper.waveDepthForWidth(screenWidth);
        final bottomHeight = h - topHeight + waveDepth;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight + waveDepth,
              child: SplashFoodHeaderBackground(
                child: Center(
                  child: FigmaAssetImage(
                    FigmaAssets.splashLogoMain,
                    width: 137,
                    height: 130,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: topHeight - 24,
              child: Center(
                child: FigmaAssetImage(FigmaAssets.chevronUpOrange, width: 14, height: 8),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomHeight,
              child: ClipPath(
                clipper: SplashWaveClipper(screenWidth: screenWidth),
                child: ColoredBox(
                  color: AppColors.surface,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(43, waveDepth + 12, 43, 24),
                    child: Column(
                      children: [
                        const Spacer(),
                        _LanguagePickerButton(label: label, onTap: onPickLanguage),
                        const SizedBox(height: 28),
                        const SplashStepDots(active: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguagePickerButton extends StatelessWidget {
  const _LanguagePickerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadii.pillButton),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  FigmaAssetImage(
                    FigmaAssets.globeWhite,
                    width: 20,
                    height: 20,
                    color: Colors.white,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.language, size: 20, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.shamelBold(size: 14, color: Colors.white),
                    ),
                  ),
                  FigmaAssetImage(
                    FigmaAssets.chevronDownWhite,
                    width: 14,
                    height: 8,
                    color: Colors.white,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
