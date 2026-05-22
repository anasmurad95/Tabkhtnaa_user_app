import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/token_storage.dart';
import 'models/user_model.dart';

class AuthRepository {
  AuthRepository(this._client, this._storage);

  final ApiClient _client;
  final TokenStorage _storage;

  Future<UserModel> login({
    required String countryCode,
    required String mobile,
    required String password,
  }) async {
    return _postAuth('/auth/login', {
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
    });
  }

  Future<UserModel> register(FormData form) async {
    final res = await _client.dio.post('/auth/register', data: form);
    return _persistUser(_mapResponse(res.data));
  }

  Future<UserModel?> loadCachedUser() async {
    final token = await _storage.getToken();
    final json = await _storage.getUserJson();
    final user = UserModel.fromJsonString(json);
    if (token == null || user == null) return null;
    return user;
  }

  Future<void> logout() => _storage.clear();

  Future<UserModel> updateProfile(FormData form) async {
    final res = await _client.dio.post('/auth/update-profile', data: form);
    final user = _persistUser(_mapResponse(res.data));
    return user;
  }

  Future<UserModel> _postAuth(String path, Map<String, dynamic> body) async {
    final res = await _client.dio.post(path, data: body);
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
    final user = UserModel.fromJson(res.data!);
    if (user.accessToken != null) {
      await _storage.saveToken(user.accessToken!);
    }
    await _storage.saveUserJson(user.toJsonString());
    return user;
  }
}
