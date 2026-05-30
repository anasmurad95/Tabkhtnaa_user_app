import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Resolves API media paths to absolute URLs for [CachedNetworkImage] / [Image.network].
String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';

  var trimmed = path.trim();
  if (trimmed.isEmpty) return '';

  // Backend accessor may double-wrap full URLs — keep the inner absolute URL.
  final doubleWrapped = RegExp(r'^https?://[^/]+/(https?://.+)$').firstMatch(trimmed);
  if (doubleWrapped != null) {
    trimmed = doubleWrapped.group(1)!;
  }

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return _normalizeMediaHost(trimmed);
  }

  final base = AppConfig.mediaBaseUrl;
  final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  return _normalizeMediaHost('$base/$normalized');
}

String _normalizeMediaHost(String url) {
  if (kIsWeb) {
    return url.replaceFirst('http://localhost:', 'http://127.0.0.1:');
  }
  return url;
}
