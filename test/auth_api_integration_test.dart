import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Optional live API test. Run with:
/// flutter test test/auth_api_integration_test.dart --dart-define=RUN_AUTH_API_TEST=true --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
void main() {
  const runLive = bool.fromEnvironment('RUN_AUTH_API_TEST', defaultValue: false);
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  if (!runLive) {
    test('auth API integration skipped (set RUN_AUTH_API_TEST=true)', () {
      expect(true, isTrue);
    });
    return;
  }

  late Dio dio;
  late String countryCode;
  late String mobile;
  late String email;
  late String password;
  late String token;
  late int userId;

  setUpAll(() {
    final suffix = DateTime.now().millisecondsSinceEpoch % 1000000;
    mobile = '79${suffix.toString().padLeft(7, '0').substring(0, 7)}';
    email = 'flutter_e2e_$suffix@test.local';
    password = 'Test1234';
    countryCode = '962';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json', 'lang': 'ar'},
      queryParameters: {'lang': 'ar'},
    ));
  });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? json,
    String? bearer,
    FormData? form,
  }) async {
    final res = await dio.post(
      path,
      data: form ?? json,
      options: Options(headers: bearer != null ? {'Authorization': 'Bearer $bearer'} : null),
    );
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue, reason: res.data.toString());
    return body;
  }

  test('register → send-sms → mobile-verified', () async {
    final png = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    final reg = await post(
      '/auth/register',
      form: FormData.fromMap({
        'name': 'Flutter E2E',
        'email': email,
        'mobile': mobile,
        'country_code': countryCode,
        'residence_country_id': 111,
        'dob': '1995-06-15',
        'gender': 'male',
        'type': 'client',
        'password': password,
        'password_confirmation': password,
        'profile_image': MultipartFile.fromBytes(png, filename: 'profile.png'),
      }),
    );
    final user = Map<String, dynamic>.from(reg['data'] as Map);
    token = user['access_token'] as String;
    userId = (user['id'] as num).toInt();

    final sms = await post('/auth/send-sms', bearer: token);
    expect(sms['data']['sms_verify'], isNotNull);

    await post('/auth/mobile-verified', json: {'user_id': userId}, bearer: token);
  });

  test('login succeeds with backend country_code format', () async {
    final login = await post('/auth/login', json: {
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
    });
    expect(login['data']['access_token'], isNotEmpty);
  });

  test('forget-password → reset-password → login', () async {
    final fp = await post('/auth/forget-password', json: {
      'country_code': countryCode,
      'mobile': mobile,
    });
    final data = Map<String, dynamic>.from(fp['data'] as Map);
    final resetToken = data['reset_password_token'] as String;
    final newPassword = 'NewPass$mobile';

    await post('/auth/reset-password', json: {
      'user_id': data['user_id'],
      'reset_password_token': resetToken,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    });

    await post('/auth/login', json: {
      'country_code': countryCode,
      'mobile': mobile,
      'password': newPassword,
    });
  });
}
