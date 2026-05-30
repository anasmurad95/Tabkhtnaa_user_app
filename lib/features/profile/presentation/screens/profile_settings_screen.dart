import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_language_dialog.dart';
import '../widgets/profile_menu_widgets.dart';
import 'change_password_screen.dart';

/// Figma — اعدادات بروفايل
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TranslationProvider>().loadLanguages();
    });
  }

  Future<void> _save(UserModel updated) async {
    final ok = await context.read<ProfileProvider>().updateProfile(updated);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ProfileProvider>().error ?? 'تعذر الحفظ')),
      );
    }
  }

  Future<void> _editTextField({
    required String title,
    required String initial,
    TextInputType keyboard = TextInputType.text,
    required Future<void> Function(String value) onSave,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title, style: AppTypography.shamelBold(size: 14)),
          content: TextField(
            controller: controller,
            keyboardType: keyboard,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('حفظ')),
          ],
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      await onSave(result);
    }
  }

  Future<void> _pickGender(UserModel user) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('ذكر'), onTap: () => Navigator.pop(ctx, 'male')),
            ListTile(title: const Text('أنثى'), onTap: () => Navigator.pop(ctx, 'female')),
            ListTile(title: const Text('آخر'), onTap: () => Navigator.pop(ctx, 'other')),
          ],
        ),
      ),
    );
    if (picked != null) {
      await _save(user.copyWith(gender: picked));
    }
  }

  Future<void> _pickDob(UserModel user) async {
    final initial = DateTime.tryParse(user.dob ?? '') ?? DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final iso = picked.toIso8601String().split('T').first;
      await _save(user.copyWith(dob: iso));
    }
  }

  Future<void> _pickLanguage(UserModel user) async {
    final l10n = context.read<TranslationProvider>();
    final options = profileLanguageOptions(l10n.languages);
    final selected = options.where((l) => l.code == (user.defLang ?? l10n.lang)).firstOrNull ??
        options.first;

    final picked = await showProfileLanguageDialog(
      context,
      languages: options,
      selected: selected,
      title: context.tr('choose_language', fallback: 'اختار اللغة'),
    );
    if (picked == null) return;

    await l10n.selectLanguage(picked.code);

    if (['ar', 'en', 'fr'].contains(picked.code)) {
      await _save(user.copyWith(defLang: picked.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final user = profile.user;
    final l10n = context.watch<TranslationProvider>();
    final langOptions = profileLanguageOptions(l10n.languages);

    return AppPageScaffold(
      title: context.tr('profile_settings', fallback: 'اعدادات بروفايل'),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
              children: [
                ProfileCard(
                  children: [
                    ProfileSettingsRow(
                      label: '',
                      value: user.name,
                      icon: Icons.person_outline,
                      onTap: () => _editTextField(
                        title: context.tr('name', fallback: 'الاسم'),
                        initial: user.name,
                        onSave: (v) => _save(user.copyWith(name: v)),
                      ),
                    ),
                    ProfileSettingsRow(
                      label: '',
                      value: formatPhone(user.countryCode, user.mobile),
                      icon: Icons.phone_outlined,
                      onTap: () => _editTextField(
                        title: context.tr('phone_number', fallback: 'رقم الهاتف'),
                        initial: user.mobile ?? '',
                        keyboard: TextInputType.phone,
                        onSave: (v) => _save(user.copyWith(mobile: v)),
                      ),
                    ),
                    ProfileSettingsRow(
                      label: '',
                      value: user.email ?? '—',
                      icon: Icons.alternate_email,
                      onTap: () => _editTextField(
                        title: 'Email',
                        initial: user.email ?? '',
                        keyboard: TextInputType.emailAddress,
                        onSave: (v) => _save(user.copyWith(email: v)),
                      ),
                    ),
                    ProfileSettingsRow(
                      label: '',
                      value: '********',
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      ),
                    ),
                    ProfileSettingsRow(
                      label: '',
                      value: genderDisplayLabel(user.gender),
                      icon: Icons.wc_outlined,
                      onTap: () => _pickGender(user),
                    ),
                    ProfileSettingsRow(
                      label: '',
                      value: formatDob(user.dob),
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _pickDob(user),
                    ),
                    ProfileSettingsRow(
                      label: '',
                      value: languageDisplayLabel(user.defLang ?? l10n.lang, langOptions),
                      icon: Icons.translate,
                      showDivider: false,
                      onTap: () => _pickLanguage(user),
                    ),
                  ],
                ),
                if (profile.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
              ],
            ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
