import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding completion flag (3-screen flow lives in [SplashOnboardingFlow]).
abstract final class OnboardingScreen {
  static const prefKey = 'onboarding_complete';

  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKey) ?? false;
  }

  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);
  }
}
