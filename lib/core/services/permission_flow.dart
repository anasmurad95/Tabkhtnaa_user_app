import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../features/localization/data/models/app_language.dart';
import '../../features/localization/presentation/providers/translation_provider.dart';
import '../../features/localization/presentation/widgets/language_picker_sheet.dart';
import '../widgets/permission_prompt_dialog.dart';
import 'permission_prompt_storage.dart';

/// Shows photo then location permission dialogs once per install/account setup.
Future<void> runPermissionPromptFlowIfNeeded(BuildContext context) async {
  if (await PermissionPromptStorage.hasShown()) return;
  if (!context.mounted) return;

  await _showPhotosPrompt(context);
  if (!context.mounted) return;

  await _showLocationPrompt(context);
  if (!context.mounted) return;

  await PermissionPromptStorage.markShown();
}

Future<void> _openLanguagePicker(BuildContext context) async {
  final l10n = context.read<TranslationProvider>();
  final languages = l10n.languages;
  final selected = languages.cast<AppLanguage?>().firstWhere(
        (l) => l?.code == l10n.lang,
        orElse: () => null,
      );
  final picked = await showLanguagePickerSheet(
    context,
    languages: languages,
    selected: selected,
  );
  if (picked != null && context.mounted) {
    await l10n.selectLanguage(picked.code);
  }
}

Future<void> _showPhotosPrompt(BuildContext context) async {
  final allow = await showPermissionPromptDialog(
    context,
    kind: PermissionPromptKind.photos,
    onLanguageTap: () => _openLanguagePicker(context),
  );
  if (allow == true && !kIsWeb) {
    await _requestPhotosPermission();
  }
}

Future<void> _showLocationPrompt(BuildContext context) async {
  final allow = await showPermissionPromptDialog(
    context,
    kind: PermissionPromptKind.location,
    onLanguageTap: () => _openLanguagePicker(context),
  );
  if (allow == true && !kIsWeb) {
    await _requestLocationPermission();
  }
}

Future<void> _requestPhotosPermission() async {
  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.photos.request();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Permission.photos.request();
    }
  } catch (_) {
    // Graceful skip on unsupported platforms (e.g. web).
  }
}

Future<void> _requestLocationPermission() async {
  try {
    if (kIsWeb) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  } catch (_) {
    // Graceful skip.
  }
}
