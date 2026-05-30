import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/app_language.dart';

/// Shows the language list as a modal bottom sheet.
Future<AppLanguage?> showLanguagePickerSheet(
  BuildContext context, {
  required List<AppLanguage> languages,
  AppLanguage? selected,
  bool loading = false,
  String? error,
}) {
  return showModalBottomSheet<AppLanguage>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      if (loading) {
        return const SafeArea(
          child: SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        );
      }

      if (languages.isEmpty) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error ?? 'تعذر تحميل اللغات',
                  textAlign: TextAlign.center,
                  style: AppTypography.shamelBook(size: 14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        );
      }

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
            if (error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                ),
              ),
            ...languages.map(
              (lang) => ListTile(
                title: Text(
                  lang.native,
                  textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
                  style: AppTypography.shamelBold(size: 14),
                ),
                subtitle: Text(lang.name),
                trailing: selected?.code == lang.code
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
}
