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
      userId: parseJsonIntOrNull(json['user_id']),
      userName: json['user_name']?.toString(),
      categoryId: parseJsonIntOrNull(json['category_id']),
    );
  }
}
