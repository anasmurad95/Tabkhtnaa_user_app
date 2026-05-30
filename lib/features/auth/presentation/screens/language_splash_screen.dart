import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../localization/data/models/app_language.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import '../../../localization/presentation/widgets/language_picker_sheet.dart';
import '../widgets/splash_language_page_body.dart';

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
    unawaited(l10n.loadLanguages());

    final picked = await showLanguagePickerSheet(
      context,
      languages: l10n.languages,
      selected: _selected,
      error: l10n.error,
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SplashLanguagePageBody(onPickLanguage: _openLanguagePicker),
      ),
    );
  }
}
