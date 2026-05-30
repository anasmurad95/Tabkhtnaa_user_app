import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_providers.dart';
import 'core/l10n/locale_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/splash_onboarding_flow.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/main_shell_gate.dart';
import 'features/localization/presentation/providers/translation_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';

class TabkhtnaaApp extends StatelessWidget {
  const TabkhtnaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(),
      child: Consumer2<ThemeProvider, TranslationProvider>(
        builder: (_, theme, l10n, _) {
          return MaterialApp(
            title: 'Tabkhtnaa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            locale: Locale(l10n.lang),
            builder: (context, child) {
              return Directionality(
                textDirection: l10n.rtl ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const _RootRouter(),
          );
        },
      ),
    );
  }
}

class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  bool? _languageSelected;
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    final langSelected = await LocaleStorage.isLanguageSelected();
    final onboarding = await OnboardingScreen.isComplete();
    if (mounted) {
      setState(() {
        _languageSelected = langSelected;
        _onboardingDone = onboarding;
      });
    }
  }

  void _onSplashFlowComplete() {
    setState(() {
      _languageSelected = true;
      _onboardingDone = true;
    });
  }

  void _onLanguageConfirmed() {
    setState(() => _languageSelected = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<TranslationProvider>();

    if (_languageSelected == null || _onboardingDone == null || !l10n.ready) {
      return const SplashScreen();
    }

    if (!_languageSelected! || !_onboardingDone!) {
      final startPage = _languageSelected! ? 1 : 0;
      return SplashOnboardingFlow(
        startPage: startPage,
        onLanguageConfirmed: _onLanguageConfirmed,
        onFlowComplete: _onSplashFlowComplete,
      );
    }

    final auth = context.watch<AuthProvider>();
    if (auth.status == AuthStatus.unknown || auth.loading) {
      return const SplashScreen();
    }
    if (auth.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    }
    return const MainShellGate();
  }
}
