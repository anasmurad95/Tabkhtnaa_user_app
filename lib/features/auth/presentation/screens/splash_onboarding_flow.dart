import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../localization/data/models/app_language.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import '../../../localization/presentation/widgets/language_picker_sheet.dart';
import '../widgets/dont_show_again_row.dart';
import '../widgets/onboarding_header_clipper.dart';
import '../widgets/splash_language_page_body.dart';
import '../widgets/splash_step_dots.dart';
import '../widgets/splash_wave_clipper.dart';
import 'onboarding_screen.dart';

/// Three-screen splash flow: language → onboard 1 (house) → onboard 2 (meal).
class SplashOnboardingFlow extends StatefulWidget {
  const SplashOnboardingFlow({
    super.key,
    required this.startPage,
    required this.onFlowComplete,
    this.onLanguageConfirmed,
  });

  final int startPage;
  final VoidCallback onFlowComplete;
  final VoidCallback? onLanguageConfirmed;

  @override
  State<SplashOnboardingFlow> createState() => _SplashOnboardingFlowState();
}

class _SplashOnboardingFlowState extends State<SplashOnboardingFlow> {
  late final PageController _pageController;
  AppLanguage? _selectedLanguage;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startPage);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TranslationProvider>().loadLanguages();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishFlow() async {
    await OnboardingScreen.markComplete();
    if (!mounted) return;
    widget.onFlowComplete();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openLanguagePicker({bool advanceToHomeOnConfirm = true}) async {
    final l10n = context.read<TranslationProvider>();
    unawaited(l10n.loadLanguages());

    final picked = await showLanguagePickerSheet(
      context,
      languages: l10n.languages,
      selected: _selectedLanguage,
      error: l10n.error,
    );

    if (picked != null && mounted) {
      setState(() => _selectedLanguage = picked);
      await l10n.selectLanguage(picked.code);
      if (!mounted) return;
      widget.onLanguageConfirmed?.call();
      if (advanceToHomeOnConfirm) {
        _goToPage(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _LanguagePage(onPickLanguage: _openLanguagePicker),
          _OnboardingHomePage(
            dontShowAgain: _dontShowAgain,
            onDontShowChanged: (v) => setState(() => _dontShowAgain = v),
            onNext: () {
              if (_dontShowAgain) {
                _finishFlow();
              } else {
                _goToPage(2);
              }
            },
          ),
          _OnboardingMealPage(
            dontShowAgain: _dontShowAgain,
            onDontShowChanged: (v) => setState(() => _dontShowAgain = v),
            onPickLanguage: () => _openLanguagePicker(advanceToHomeOnConfirm: false),
            onNext: _finishFlow,
            onLetsStart: _finishFlow,
          ),
        ],
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.onPickLanguage});

  final VoidCallback onPickLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SplashLanguagePageBody(onPickLanguage: onPickLanguage),
    );
  }
}

class _OnboardingHomePage extends StatelessWidget {
  const _OnboardingHomePage({
    required this.dontShowAgain,
    required this.onDontShowChanged,
    required this.onNext,
  });

  final bool dontShowAgain;
  final ValueChanged<bool> onDontShowChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<TranslationProvider>();
    final title = l10n.tr('onboarding_home_title', fallback: 'استمتع بمذاق الطعام المنزلي');
    final nextLabel = l10n.tr('next', fallback: 'التالي');
    final dontShowLabel = l10n.tr('dont_show_again', fallback: 'عدم إظهار الشاشة مرة اخرى');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      FigmaAssetImage(FigmaAssets.loginHeroHouse, width: 220, height: 220, fit: BoxFit.contain),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.geBold(size: 18, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            FigmaAssetImage(FigmaAssets.chevronUpOrange, width: 14, height: 8),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 43),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.pillButton),
                        ),
                      ),
                      child: Text(nextLabel, style: AppTypography.shamelBold(size: 14, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DontShowAgainRow(
                    label: dontShowLabel,
                    value: dontShowAgain,
                    onChanged: onDontShowChanged,
                  ),
                  const SizedBox(height: 20),
                  const SplashStepDots(active: 1),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _OnboardingMealPage extends StatelessWidget {
  const _OnboardingMealPage({
    required this.dontShowAgain,
    required this.onDontShowChanged,
    required this.onPickLanguage,
    required this.onNext,
    required this.onLetsStart,
  });

  final bool dontShowAgain;
  final ValueChanged<bool> onDontShowChanged;
  final VoidCallback onPickLanguage;
  final VoidCallback onNext;
  final VoidCallback onLetsStart;

  static const _illustrationSize = 200.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<TranslationProvider>();
    final title = l10n.tr('onboarding_meal_title', fallback: 'استمتع بالوجبة المنزلية');
    final subtitle = l10n.tr(
      'onboarding_meal_subtitle',
      fallback: 'المحضرة بالمنزل مع أمهر الطباخين المحليين',
    );
    final nextLabel = l10n.tr('next', fallback: 'التالي');
    final startLabel = l10n.tr('lets_start', fallback: 'هيا نبدأ');
    final dontShowLabel = l10n.tr('dont_show_again', fallback: 'عدم إظهار الشاشة مرة اخرى');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final headerH = constraints.maxHeight * 0.48;

            return Stack(
              clipBehavior: Clip.none,
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
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          32,
                          _illustrationSize * 0.42,
                          32,
                          0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: AppTypography.geBold(size: 18, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(43, 0, 43, 16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: OutlinedButton(
                              onPressed: onLetsStart,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadii.pillButton),
                                ),
                              ),
                              child: Text(startLabel, style: AppTypography.shamelBold(size: 14)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadii.pillButton),
                                ),
                              ),
                              child: Text(nextLabel, style: AppTypography.shamelBold(size: 14, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DontShowAgainRow(
                            label: dontShowLabel,
                            value: dontShowAgain,
                            onChanged: onDontShowChanged,
                          ),
                          const SizedBox(height: 16),
                          const SplashStepDots(active: 2),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: headerH - _illustrationSize * 0.45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FigmaAssetImage(
                      FigmaAssets.onboardingEatingMan,
                      width: _illustrationSize,
                      height: _illustrationSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onPickLanguage,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: FigmaAssetImage(
                              FigmaAssets.globeWhite,
                              width: 24,
                              height: 24,
                              color: Colors.white,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.language, size: 24, color: Colors.white),
                            ),
                          ),
                        ),
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
