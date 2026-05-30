import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/auth/data/models/user_model.dart';

void main() {
  test('UserModel.fromJson accepts string id and residence_country_id', () {
    final user = UserModel.fromJson({
      'id': '111',
      'name': 'Test User',
      'country_code': '962',
      'mobile': '781780558',
      'access_token': 'token',
      'residence_country_id': '111',
    });

    expect(user.id, 111);
    expect(user.residenceCountryId, 111);
  });

  test('UserModel.fromJson accepts numeric id fields', () {
    final user = UserModel.fromJson({
      'id': 42,
      'name': 'Test',
      'residence_country_id': 111,
    });

    expect(user.id, 42);
    expect(user.residenceCountryId, 111);
  });
}
