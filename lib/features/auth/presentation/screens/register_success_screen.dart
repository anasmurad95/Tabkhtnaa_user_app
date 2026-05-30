import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../home/presentation/screens/main_shell_gate.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_header_clipper.dart';
import '../widgets/splash_wave_clipper.dart';
import 'login_screen.dart';

/// Flow C — تم بنجاح
class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

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
            final headerH = constraints.maxHeight * 0.42;

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
                        padding: const EdgeInsets.fromLTRB(43, 32, 43, 24),
                        child: Column(
                          children: [
                            Text(
                              context.tr('registration_success', fallback: 'تم بنجاح'),
                              style: AppTypography.shamelBold(size: 22, color: AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr(
                                'registration_success_hint',
                                fallback: 'تم إكمال عملية التسجيل بنجاح',
                              ),
                              textAlign: TextAlign.center,
                              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const MainShellGate()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23.5),
                                  ),
                                ),
                                child: Text(
                                  context.tr('back_to_home', fallback: 'العودة للرئيسية'),
                                  style: AppTypography.shamelBold(size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () async {
                                await context.read<AuthProvider>().logout();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                              child: Text(
                                context.tr('login', fallback: 'تسجيل دخول'),
                                style: AppTypography.shamelBold(size: 12, color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: headerH * 0.55,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: headerH * 0.38,
                  left: 0,
                  right: 0,
                  child: Text(
                    context.tr('registration_success', fallback: 'تم بنجاح'),
                    textAlign: TextAlign.center,
                    style: AppTypography.shamelBold(size: 14, color: Colors.white),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
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
              ],
            );
          },
        ),
      ),
    );
  }
}
