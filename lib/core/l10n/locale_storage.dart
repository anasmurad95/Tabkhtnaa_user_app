import 'package:shared_preferences/shared_preferences.dart';

class LocaleStorage {
  static const languageSelectedKey = 'language_selected';
  static const appLanguageKey = 'app_language';
  static const defaultLang = 'ar';

  static Future<bool> isLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(languageSelectedKey) ?? false;
  }

  static Future<void> markLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(languageSelectedKey, true);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(appLanguageKey) ?? defaultLang;
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appLanguageKey, code);
  }
}
