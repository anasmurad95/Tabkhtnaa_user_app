import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class SettingsRepository {
  SettingsRepository(this._client);

  final ApiClient _client;

  Map<String, dynamic>? _cached;

  Future<Map<String, dynamic>> getSettings({bool force = false}) async {
    if (_cached != null && !force) return _cached!;

    final res = await _client.dio.get('/settings');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Settings unavailable');
    }
    _cached = parsed.data as Map<String, dynamic>;
    return _cached!;
  }

  Future<Map<String, dynamic>> companyInfo() async {
    final settings = await getSettings();
    return (settings['company'] as Map<String, dynamic>?) ?? {};
  }

  double taxPercentage(Map<String, dynamic> settings) {
    return double.tryParse(settings['tax_percentage']?.toString() ?? '15') ?? 15;
  }

  double deliveryFee(Map<String, dynamic> settings) {
    return double.tryParse(settings['delivery_fee']?.toString() ?? '2.5') ?? 2.5;
  }
}
