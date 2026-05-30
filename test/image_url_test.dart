import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/utils/image_url.dart';

void main() {
  test('resolveMediaUrl keeps absolute http URLs', () {
    expect(
      resolveMediaUrl('http://127.0.0.1:8000/images/categorise/Bakery-01.png'),
      'http://127.0.0.1:8000/images/categorise/Bakery-01.png',
    );
  });

  test('resolveMediaUrl prepends media base for relative paths', () {
    expect(
      resolveMediaUrl('/images/categorise/Salad-01.png'),
      contains('/images/categorise/Salad-01.png'),
    );
    expect(
      resolveMediaUrl('images/categorise/Salad-01.png'),
      contains('/images/categorise/Salad-01.png'),
    );
  });

  test('resolveMediaUrl unwraps double-wrapped backend URLs', () {
    expect(
      resolveMediaUrl(
        'http://127.0.0.1:8000/http://127.0.0.1:8000/images/categorise/Bakery-01.png',
      ),
      'http://127.0.0.1:8000/images/categorise/Bakery-01.png',
    );
  });

  test('resolveMediaUrl returns empty for null/blank', () {
    expect(resolveMediaUrl(null), '');
    expect(resolveMediaUrl(''), '');
    expect(resolveMediaUrl('   '), '');
  });
}
