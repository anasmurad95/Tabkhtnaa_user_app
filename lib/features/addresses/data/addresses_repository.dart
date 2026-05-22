import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class AddressesRepository {
  AddressesRepository(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _client.dio.get('/addresses/list');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) throw ApiException(parsed.errorMsg ?? 'Failed');
    final data = parsed.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final res = await _client.dio.post('/addresses/create', data: payload);
    _ensureOk(res.data);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    final res = await _client.dio.post('/addresses/update', data: {'id': id, ...payload});
    _ensureOk(res.data);
  }

  Future<void> delete(int id) async {
    final res = await _client.dio.post('/addresses/delete', data: {'id': id});
    _ensureOk(res.data);
  }

  void _ensureOk(dynamic raw) {
    final parsed = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!parsed.status) throw ApiException(parsed.errorMsg ?? 'Failed');
  }
}
