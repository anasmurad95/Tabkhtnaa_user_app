import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/data/models/app_language.dart';

/// Figma modal — اختار اللغة (center dialog with 4 language buttons).
Future<AppLanguage?> showProfileLanguageDialog(
  BuildContext context, {
  required List<AppLanguage> languages,
  required AppLanguage? selected,
  String title = 'اختار اللغة',
}) {
  return showDialog<AppLanguage>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTypography.shamelBold(size: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
                const SizedBox(height: 20),
                ...languages.map(
                  (lang) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LanguageButton(
                      label: lang.native,
                      selected: selected?.code == lang.code,
                      onTap: () => Navigator.pop(ctx, lang),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.primary : AppColors.surface,
          foregroundColor: selected ? Colors.white : AppColors.textMuted,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.5)),
        ),
        child: Text(label, style: AppTypography.shamelBold(size: 14)),
      ),
    );
  }
}

/// Ensures Figma's 4 languages even if API returns fewer.
List<AppLanguage> profileLanguageOptions(List<AppLanguage> fromApi) {
  const defaults = [
    AppLanguage(code: 'ar', name: 'Arabic', native: 'العربية', rtl: true),
    AppLanguage(code: 'en', name: 'English', native: 'الانجليزية', rtl: false),
    AppLanguage(code: 'fr', name: 'French', native: 'الفرنسية', rtl: false),
    AppLanguage(code: 'tr', name: 'Turkish', native: 'التركية', rtl: false),
  ];

  final merged = <String, AppLanguage>{for (final l in defaults) l.code: l};
  for (final l in fromApi) {
    merged[l.code] = l;
  }
  return ['ar', 'en', 'fr', 'tr'].map((c) => merged[c]!).toList();
}

String languageDisplayLabel(String code, List<AppLanguage> languages) {
  final match = languages.where((l) => l.code == code);
  if (match.isNotEmpty) return match.first.native;
  switch (code) {
    case 'ar':
      return 'Arabic';
    case 'en':
      return 'English';
    case 'fr':
      return 'French';
    case 'tr':
      return 'Turkish';
    default:
      return code;
  }
}

String genderDisplayLabel(String? gender) {
  switch (gender) {
    case 'male':
      return 'ذكر';
    case 'female':
      return 'أنثى';
    default:
      return '—';
  }
}

String formatDob(String? dob) {
  if (dob == null || dob.isEmpty) return '—';
  final parsed = DateTime.tryParse(dob);
  if (parsed == null) return dob;
  return '${parsed.day}/${parsed.month}/${parsed.year}';
}

String formatPhone(String? countryCode, String? mobile) {
  if (mobile == null || mobile.isEmpty) return '—';
  final cc = countryCode ?? '';
  return cc.isEmpty ? mobile : '$cc-$mobile';
}
