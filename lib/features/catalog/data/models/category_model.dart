class CategoryModel {
  final int id;
  final String name;
  final String? image;

  const CategoryModel({required this.id, required this.name, this.image});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}
