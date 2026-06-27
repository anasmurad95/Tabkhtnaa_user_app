import '../../../../core/utils/json_parse.dart';

class MealModel {
  final int id;
  final String name;
  final double price;
  final String? image;
  final String? description;
  final int? userId;
  final String? userName;
  final int? categoryId;

  const MealModel({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.description,
    this.userId,
    this.userName,
    this.categoryId,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: parseJsonInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      userId: _parseMakerId(json),
      userName: json['user_name']?.toString(),
      categoryId: parseJsonIntOrNull(json['category_id']),
    );
  }

  /// Chef / maker id — API may use snake_case, camelCase, or nested `user`.
  static int? _parseMakerId(Map<String, dynamic> json) {
    final direct = parseJsonIntOrNull(json['user_id']) ??
        parseJsonIntOrNull(json['userId']) ??
        parseJsonIntOrNull(json['chef_id']) ??
        parseJsonIntOrNull(json['maker_id']);
    if (direct != null) return direct;

    final user = json['user'];
    if (user is Map<String, dynamic>) {
      return parseJsonIntOrNull(user['id']);
    }
    return null;
  }

  MealModel withMakerId(int makerId) => MealModel(
        id: id,
        name: name,
        price: price,
        image: image,
        description: description,
        userId: makerId,
        userName: userName,
        categoryId: categoryId,
      );
}
