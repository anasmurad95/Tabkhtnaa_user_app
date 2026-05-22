import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'lang': AppConfig.defaultLang,
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final lang = _dio.options.headers['lang']?.toString() ?? AppConfig.defaultLang;
          options.headers['lang'] = lang;
          options.queryParameters = {
            ...options.queryParameters,
            'lang': lang,
          };
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final msg = _parseError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException(msg, statusCode: error.response?.statusCode),
            ),
          );
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  Dio get dio => _dio;

  void setLanguage(String lang) {
    _dio.options.headers['lang'] = lang;
  }

  String _parseError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['error_msg'] != null) {
      return data['error_msg'].toString();
    }
    return error.message ?? 'Network error';
  }
}
