class ChefModel {
  final int id;
  final String name;
  final String? profileImage;
  final double? distance;
  final Map<String, dynamic>? ratings;

  const ChefModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.distance,
    this.ratings,
  });

  factory ChefModel.fromJson(Map<String, dynamic> json) {
    return ChefModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      distance: double.tryParse(json['distance']?.toString() ?? ''),
      ratings: json['raties'] as Map<String, dynamic>?,
    );
  }
}
