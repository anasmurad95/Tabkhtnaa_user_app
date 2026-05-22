class AppConfig {
  /// Android emulator → host machine. Use your LAN IP on a physical device.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String defaultLang = 'ar';
}
