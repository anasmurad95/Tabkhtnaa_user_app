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
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      userId: json['user_id'] as int?,
      userName: json['user_name']?.toString(),
      categoryId: json['category_id'] as int?,
    );
  }
}
