import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Android emulator → `10.0.2.2`; web/desktop → `127.0.0.1`. Override via `--dart-define=API_BASE_URL=...`.
  static String get apiBaseUrl {
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    return 'http://10.0.2.2:8000/api/v1';
  }

  /// Host root for static media (strip trailing `/api/v1` from [apiBaseUrl]).
  static String get mediaBaseUrl {
    var base = apiBaseUrl;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    const suffix = '/api/v1';
    if (base.endsWith(suffix)) {
      return base.substring(0, base.length - suffix.length);
    }
    return base;
  }

  static const String defaultLang = 'ar';
}
