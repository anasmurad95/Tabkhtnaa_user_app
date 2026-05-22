import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../data/localization_repository.dart';
import '../../data/models/app_language.dart';

class TranslationProvider extends ChangeNotifier {
  TranslationProvider(this._repository, this._apiClient);

  final LocalizationRepository _repository;
  final ApiClient _apiClient;

  String _lang = LocaleStorage.defaultLang;
  bool _rtl = true;
  bool _ready = false;
  bool _loading = false;
  String? _error;
  List<AppLanguage> _languages = const [];
  Map<String, String> _strings = {};

  String get lang => _lang;
  bool get rtl => _rtl;
  bool get ready => _ready;
  bool get loading => _loading;
  String? get error => _error;
  List<AppLanguage> get languages => _languages;

  String tr(String key, {String? fallback}) {
    final value = _strings[key];
    if (value != null && value.isNotEmpty) return value;
    return fallback ?? AppStrings.fallbacks[key] ?? key;
  }

  Future<void> bootstrap() async {
    _lang = await LocaleStorage.getLanguage();
    _rtl = _lang == 'ar';
    _apiClient.setLanguage(_lang);
    if (await LocaleStorage.isLanguageSelected()) {
      await _loadTranslations();
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> loadLanguages() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _languages = await _repository.fetchLanguages();
      if (_languages.isEmpty) {
        _languages = _defaultLanguages;
      }
    } catch (e) {
      _languages = _defaultLanguages;
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> selectLanguage(String code) async {
    _lang = code;
    _rtl = code == 'ar';
    await LocaleStorage.setLanguage(code);
    _apiClient.setLanguage(code);
    await _loadTranslations();
    await LocaleStorage.markLanguageSelected();
    notifyListeners();
  }

  Future<void> _loadTranslations() async {
    try {
      _strings = await _repository.fetchTranslations(_lang);
    } catch (_) {
      _strings = {};
    }
  }

  static const _defaultLanguages = [
    AppLanguage(code: 'ar', name: 'العربية', native: 'العربية', rtl: true),
    AppLanguage(code: 'en', name: 'English', native: 'English', rtl: false),
  ];
}
