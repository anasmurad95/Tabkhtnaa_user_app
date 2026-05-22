import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/app_language.dart';

class LocalizationRepository {
  LocalizationRepository(this._api);

  final ApiClient _api;

  Future<List<AppLanguage>> fetchLanguages() async {
    final response = await _api.dio.get<Map<String, dynamic>>('/languages');
    final parsed = ApiResponse<List<AppLanguage>>.fromJson(
      response.data ?? {},
      parser: (value) {
        if (value is! List) return <AppLanguage>[];
        return value
            .whereType<Map>()
            .map((e) => AppLanguage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    if (!parsed.status || parsed.data == null) {
      throw Exception(parsed.errorMsg ?? 'Failed to load languages');
    }
    return parsed.data!;
  }

  Future<Map<String, String>> fetchTranslations(String lang) async {
    final response = await _api.dio.get<Map<String, dynamic>>(
      '/translate',
      queryParameters: {'lang': lang},
    );
    final parsed = ApiResponse<Map<String, String>>.fromJson(
      response.data ?? {},
      parser: (value) {
        if (value is Map) {
          return value.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        }
        return <String, String>{};
      },
    );
    if (!parsed.status || parsed.data == null) {
      throw Exception(parsed.errorMsg ?? 'Failed to load translations');
    }
    return parsed.data!;
  }
}
