import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/catalog/data/models/category_model.dart';

void main() {
  test('fromJson handles null/missing name and key', () {
    final cat1 = CategoryModel.fromJson({'id': 1, 'key': 'salad', 'icon': null});
    expect(cat1.key, 'salad');
    expect(cat1.name, 'salad');
    expect(cat1.image, isNull);

    final cat2 = CategoryModel.fromJson({'id': 2, 'name': null, 'icon': 'http://x/a.png'});
    expect(cat2.key, 'category_2');
    expect(cat2.name, 'category_2');

    final cat3 = CategoryModel.fromJson({'id': 3, 'slug': 'pasta', 'name': 'Pasta'});
    expect(cat3.key, 'pasta');
    expect(cat3.name, 'Pasta');
    expect(cat3.displayName, 'Pasta');
  });
}
