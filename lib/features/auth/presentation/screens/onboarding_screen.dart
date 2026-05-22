import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import 'login_screen.dart';

/// Onboarding — Figma 0:5253, 0:5201 (brand orange flow)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const prefKey = 'onboarding_complete';

  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKey) ?? false;
  }

  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _pages = [
    ('onboarding_1_title', 'onboarding_1_body'),
    ('onboarding_2_title', 'onboarding_2_body'),
    ('onboarding_3_title', 'onboarding_3_body'),
    ('onboarding_location_title', 'onboarding_location_body'),
    ('onboarding_terms_title', 'onboarding_terms_body'),
  ];

  Future<void> _finish() async {
    await OnboardingScreen.markComplete();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(FigmaAssets.splashBgFood, fit: BoxFit.cover),
            Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        context.tr('skip', fallback: 'تخطي'),
                        style: AppTypography.shamelBold(size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemCount: _pages.length,
                      itemBuilder: (_, i) {
                        final p = _pages[i];
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(FigmaAssets.splashLogoMain, width: 100, height: 95),
                              const SizedBox(height: 32),
                              Text(
                                context.tr(p.$1, fallback: p.$1),
                                textAlign: TextAlign.center,
                                style: AppTypography.shamelBold(size: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.tr(p.$2, fallback: p.$2),
                                textAlign: TextAlign.center,
                                style: AppTypography.shamelBook(size: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(43, 0, 43, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _next,
                        child: Text(
                          _index == _pages.length - 1
                              ? context.tr('get_started', fallback: 'ابدأ')
                              : context.tr('next', fallback: 'التالي'),
                        ),
                      ),
                    ),
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
