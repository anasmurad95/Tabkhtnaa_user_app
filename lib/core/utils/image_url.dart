import '../config/app_config.dart';

String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.apiBaseUrl.replaceAll('/api/v1', '');
  final normalized = path.startsWith('/') ? path.substring(1) : path;
  return '$base/$normalized';
}
