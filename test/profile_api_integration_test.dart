import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Live profile API test. Run with:
/// flutter test test/profile_api_integration_test.dart --dart-define=RUN_PROFILE_API_TEST=true --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
void main() {
  const runLive = bool.fromEnvironment('RUN_PROFILE_API_TEST', defaultValue: false);
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  if (!runLive) {
    test('profile API integration skipped (set RUN_PROFILE_API_TEST=true)', () {
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

  setUpAll(() async {
    final suffix = DateTime.now().millisecondsSinceEpoch % 1000000;
    mobile = '79${suffix.toString().padLeft(7, '0').substring(0, 7)}';
    email = 'profile_e2e_$suffix@test.local';
    password = 'Test1234';
    countryCode = '962';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json', 'lang': 'ar'},
      queryParameters: {'lang': 'ar'},
    ));

    final png = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];

    final reg = await dio.post(
      '/auth/register',
      data: FormData.fromMap({
        'name': 'Profile E2E',
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
    final regBody = Map<String, dynamic>.from(reg.data as Map);
    expect(regBody['status'], isTrue, reason: reg.data.toString());
    final user = Map<String, dynamic>.from(regBody['data'] as Map);
    token = user['access_token'] as String;
    userId = (user['id'] as num).toInt();
  });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? json,
    FormData? form,
  }) async {
    final res = await dio.post(
      path,
      data: form ?? json,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue, reason: res.data.toString());
    return body;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await dio.get(
      path,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue, reason: res.data.toString());
    return body;
  }

  test('GET /languages returns ar, en, fr, tr', () async {
    final res = await dio.get('/languages');
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final langs = (body['data'] as List).map((e) => (e as Map)['code']).toList();
    expect(langs, containsAll(['ar', 'en', 'fr', 'tr']));
  });

  test('POST /auth/update-profile updates name and def_lang', () async {
    final updated = await post('/auth/update-profile', json: {
      'name': 'Profile Updated',
      'email': email,
      'mobile': mobile,
      'country_code': countryCode,
      'residence_country_id': 111,
      'dob': '1995-06-15',
      'gender': 'female',
      'def_lang': 'en',
    });
    final data = Map<String, dynamic>.from(updated['data'] as Map);
    expect(data['name'], 'Profile Updated');
    expect(data['gender'], 'female');
    expect(data['def_lang'], 'en');
  });

  test('POST /auth/online-status toggles status', () async {
    final res = await post('/auth/online-status', json: {'online_status': 'unavailable'});
    final data = Map<String, dynamic>.from(res['data'] as Map);
    expect(data['online_status'], 'unavailable');
  });

  test('GET /auth/term-and-condition returns text', () async {
    final res = await get('/auth/term-and-condition');
    final data = res['data'];
    if (data is Map) {
      expect(data.containsKey('text'), isTrue);
    } else {
      expect(data, isNull);
    }
  });

  test('POST /auth/change-password updates password', () async {
    const newPassword = 'NewPass9999';
    await post('/auth/change-password', json: {
      'current_password': password,
      'password': newPassword,
      'password_confirmation': newPassword,
    });

    final login = await dio.post('/auth/login', data: {
      'country_code': countryCode,
      'mobile': mobile,
      'password': newPassword,
    });
    final body = Map<String, dynamic>.from(login.data as Map);
    expect(body['status'], isTrue);
  });
}
