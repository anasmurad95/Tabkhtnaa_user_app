import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/utils/phone_utils.dart';

void main() {
  group('PhoneUtils', () {
    test('normalizeCountryCode strips plus and leading zeros', () {
      expect(PhoneUtils.normalizeCountryCode('+962'), '962');
      expect(PhoneUtils.normalizeCountryCode('00962'), '962');
      expect(PhoneUtils.normalizeCountryCode('962'), '962');
      expect(PhoneUtils.normalizeCountryCode('+966'), '966');
    });

    test('normalizeMobile strips leading zeros', () {
      expect(PhoneUtils.normalizeMobile('079600135'), '79600135');
      expect(PhoneUtils.normalizeMobile('79600135'), '79600135');
    });
  });
}
