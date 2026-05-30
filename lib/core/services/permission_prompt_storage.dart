import 'package:shared_preferences/shared_preferences.dart';

class PermissionPromptStorage {
  static const permissionsPromptShownKey = 'permissions_prompt_shown';

  static Future<bool> hasShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(permissionsPromptShownKey) ?? false;
  }

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(permissionsPromptShownKey, true);
  }
}
