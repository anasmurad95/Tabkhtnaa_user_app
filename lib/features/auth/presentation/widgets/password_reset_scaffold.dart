import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import 'onboarding_header_clipper.dart';
import 'password_reset_step_dots.dart';
import 'splash_wave_clipper.dart';

/// Orange curved header + white body for the 3-step password reset flow.
class PasswordResetScaffold extends StatelessWidget {
  const PasswordResetScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.step,
    this.headerHero,
    this.onBack,
  });

  final String title;
  final Widget body;
  final int step;
  final Widget? headerHero;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final headerH = constraints.maxHeight * (headerHero != null ? 0.36 : 0.28);

            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: headerH,
                      width: double.infinity,
                      child: ClipPath(
                        clipper: OnboardingHeaderClipper(),
                        child: const SplashFoodHeaderBackground(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(43, 20, 43, 72),
                        child: body,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: headerH * 0.42,
                  left: 0,
                  right: 0,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.shamelBold(size: 14, color: Colors.white),
                  ),
                ),
                if (headerHero != null)
                  Positioned(
                    top: headerH * 0.52,
                    left: 0,
                    right: 0,
                    child: Center(child: headerHero),
                  ),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      onPressed: onBack ?? () => Navigator.maybePop(context),
                      icon: FigmaAssetImage(
                        FigmaAssets.loginBackWhite,
                        width: 22,
                        height: 22,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: PasswordResetStepDots(active: step),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Primary orange pill button used across reset flow screens.
class PasswordResetPrimaryButton extends StatelessWidget {
  const PasswordResetPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.5)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: AppTypography.shamelBold(size: 14, color: Colors.white)),
      ),
    );
  }
}
