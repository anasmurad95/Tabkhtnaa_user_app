import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/data/models/user_model.dart';

class ProfileRepository {
  ProfileRepository(this._client, this._storage);

  final ApiClient _client;
  final TokenStorage _storage;

  Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    final res = await _client.dio.post('/auth/update-profile', data: fields);
    return _persistUser(_mapResponse(res.data));
  }

  Future<UserModel> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _client.dio.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return _persistUser(_mapResponse(res.data));
  }

  Future<UserModel> updateOnlineStatus(String status) async {
    final res = await _client.dio.post('/auth/online-status', data: {
      'online_status': status,
    });
    return _persistUser(_mapResponse(res.data));
  }

  ApiResponse<Map<String, dynamic>> _mapResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid server response');
    }
    return ApiResponse.fromJson(data);
  }

  Future<UserModel> _persistUser(ApiResponse<Map<String, dynamic>> res) async {
    if (!res.status || res.data == null) {
      throw ApiException(res.errorMsg ?? 'Request failed');
    }
    final cached = UserModel.fromJsonString(await _storage.getUserJson());
    final merged = UserModel.fromJson({
      ...?cached?.toJson(),
      ...res.data!,
      if (cached?.accessToken != null) 'access_token': cached!.accessToken,
    });
    await _storage.saveUserJson(merged.toJsonString());
    return merged;
  }
}
