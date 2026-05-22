import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/data/models/app_language.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import '../widgets/splash_wave_clipper.dart';

/// Figma 0:5305 — splash + اختيار اللغة
class LanguageSplashScreen extends StatefulWidget {
  const LanguageSplashScreen({super.key, required this.onLanguageConfirmed});

  final VoidCallback onLanguageConfirmed;

  @override
  State<LanguageSplashScreen> createState() => _LanguageSplashScreenState();
}

class _LanguageSplashScreenState extends State<LanguageSplashScreen> {
  AppLanguage? _selected;

  @override
  void initState() {
    super.initState();
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

  Future<void> _openLanguagePicker() async {
    final l10n = context.read<TranslationProvider>();
    final languages = l10n.languages;
    if (languages.isEmpty) return;

    final picked = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...languages.map(
                (lang) => ListTile(
                  title: Text(
                    lang.native,
                    textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
                    style: AppTypography.shamelBold(size: 14),
                  ),
                  subtitle: Text(lang.name),
                  trailing: _selected?.code == lang.code
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, lang),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selected = picked);
      await l10n.selectLanguage(picked.code);
      if (!mounted) return;
      widget.onLanguageConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = context.watch<TranslationProvider>().tr('choose_language', fallback: 'اختيار اللغة');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final topHeight = h * 0.72;

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(FigmaAssets.splashBgFood, fit: BoxFit.cover),
                      Container(
                        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
                      ),
                      Center(
                        child: Image.asset(
                          FigmaAssets.splashLogoMain,
                          width: 137,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: topHeight - 24,
                  child: Center(
                    child: Image.asset(FigmaAssets.chevronUpOrange, width: 14, height: 8),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: h * 0.34,
                  child: ClipPath(
                    clipper: SplashWaveClipper(),
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(43, h * 0.08, 43, 24),
                        child: Column(
                          children: [
                            const Spacer(),
                            Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadii.pillButton),
                              child: InkWell(
                                onTap: _openLanguagePicker,
                                borderRadius: BorderRadius.circular(AppRadii.pillButton),
                                child: SizedBox(
                                  width: 274,
                                  height: 40,
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      const SizedBox(width: 17),
                                      Image.asset(FigmaAssets.globeWhite, width: 20, height: 20),
                                      Expanded(
                                        child: Text(
                                          label,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.shamelBold(size: 14, color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Image.asset(FigmaAssets.chevronDownWhite, width: 14, height: 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            const _FigmaStepDots(active: 0),
                          ],
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

class _FigmaStepDots extends StatelessWidget {
  const _FigmaStepDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        if (i == active) {
          return Container(
            width: 29,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
