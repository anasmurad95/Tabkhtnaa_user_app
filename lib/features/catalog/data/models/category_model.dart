import '../../../../core/utils/json_parse.dart';

class CategoryModel {
  final int id;
  final String key;
  final String name;
  final String? image;

  const CategoryModel({
    required this.id,
    required this.key,
    required this.name,
    this.image,
  });

  /// User-visible label when translation or API name is missing.
  String get displayName {
    if (name.isNotEmpty) return name;
    if (key.isNotEmpty) return key;
    return id > 0 ? 'Category $id' : '';
  }

  static String? _nonEmptyString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = parseJsonInt(json['id']);
    final key = _nonEmptyString(json['key']) ??
        _nonEmptyString(json['slug']) ??
        (id > 0 ? 'category_$id' : '');
    final name = _nonEmptyString(json['name']) ?? key;
    final image = _nonEmptyString(json['icon']) ?? _nonEmptyString(json['image']);
    return CategoryModel(
      id: id,
      key: key,
      name: name,
      image: image,
    );
  }
}
