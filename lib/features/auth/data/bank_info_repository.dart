import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class BankInfoRepository {
  BankInfoRepository(this._client);

  final ApiClient _client;

  Future<void> create(Map<String, dynamic> payload) async {
    final res = await _client.dio.post('/bank_info/create', data: payload);
    _ensureOk(res.data);
  }

  void _ensureOk(dynamic raw) {
    final parsed = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!parsed.status) throw ApiException(parsed.errorMsg ?? 'Failed');
  }
}
