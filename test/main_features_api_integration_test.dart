import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:user_app/features/catalog/data/models/category_model.dart';
import 'package:user_app/features/catalog/data/models/chef_model.dart';
import 'package:user_app/features/catalog/data/models/meal_model.dart';
import 'package:user_app/features/notifications/data/models/notification_model.dart';
import 'package:user_app/features/support/data/models/complaint_model.dart';
import 'package:user_app/features/support/data/models/sanction_model.dart';

/// Live main-features API test. Run with:
/// flutter test test/main_features_api_integration_test.dart --dart-define=RUN_MAIN_FEATURES_API_TEST=true --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
void main() {
  const runLive = bool.fromEnvironment('RUN_MAIN_FEATURES_API_TEST', defaultValue: false);
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  if (!runLive) {
    test('main features API integration skipped (set RUN_MAIN_FEATURES_API_TEST=true)', () {
      expect(true, isTrue);
    });
    return;
  }

  late Dio dio;
  late String token;
  const lat = 31.9539;
  const lng = 35.9106;

  setUpAll(() async {
    final suffix = DateTime.now().millisecondsSinceEpoch % 1000000;
    final mobile = '77${suffix.toString().padLeft(7, '0').substring(0, 7)}';
    final email = 'main_feat_$suffix@test.local';
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
        'name': 'Main Features E2E',
        'email': email,
        'mobile': mobile,
        'country_code': '962',
        'residence_country_id': 111,
        'dob': '1995-06-15',
        'gender': 'male',
        'type': 'client',
        'password': 'Test1234',
        'password_confirmation': 'Test1234',
        'profile_image': MultipartFile.fromBytes(png, filename: 'profile.png'),
      }),
    );
    final regBody = Map<String, dynamic>.from(reg.data as Map);
    expect(regBody['status'], isTrue, reason: reg.data.toString());
    token = Map<String, dynamic>.from(regBody['data'] as Map)['access_token'] as String;
  });

  Options authOpts() => Options(headers: {'Authorization': 'Bearer $token'});

  test('GET /category/list parses categories', () async {
    final res = await dio.get('/category/list', options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final list = body['data'] as List;
    for (final item in list) {
      final cat = CategoryModel.fromJson(Map<String, dynamic>.from(item as Map));
      expect(cat.id, greaterThan(0));
      expect(cat.name.isNotEmpty || cat.image != null, isTrue);
    }
  });

  test('GET /user/chefs parses chef list', () async {
    final res = await dio.get('/user/chefs', queryParameters: {
      'lat': lat,
      'long': lng,
      'radius': 30,
    }, options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final list = body['data'] as List? ?? [];
    for (final item in list) {
      ChefModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
  });

  test('GET /user/meals/list parses meals', () async {
    final res = await dio.get('/user/meals/list', queryParameters: {
      'lat': lat,
      'long': lng,
      'radius': 30,
    }, options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final list = body['data'] as List? ?? [];
    for (final item in list) {
      MealModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
  });

  test('GET /notification/list parses notifications', () async {
    final res = await dio.get('/notification/list', options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final list = body['data'] as List? ?? [];
    for (final item in list) {
      NotificationModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
  });

  test('GET /complaint/list parses complaints', () async {
    final res = await dio.get('/complaint/list', options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final list = body['data'] as List? ?? [];
    for (final item in list) {
      ComplaintModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
  });

  test('GET /user/sanction/list parses sanctions', () async {
    final res = await dio.get('/user/sanction/list', options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
    final list = body['data'] as List? ?? [];
    for (final item in list) {
      SanctionModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
  });

  test('POST /notification/seen_all succeeds', () async {
    final res = await dio.post('/notification/seen_all', options: authOpts());
    final body = Map<String, dynamic>.from(res.data as Map);
    expect(body['status'], isTrue);
  });
}
