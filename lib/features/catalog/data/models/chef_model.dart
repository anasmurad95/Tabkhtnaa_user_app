import '../../../../core/utils/json_parse.dart';

class ChefModel {
  final int id;
  final String name;
  final String? profileImage;
  final double? distance;
  final double? latitude;
  final double? longitude;
  final String? addressLabel;
  final Map<String, dynamic>? ratings;

  const ChefModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.distance,
    this.latitude,
    this.longitude,
    this.addressLabel,
    this.ratings,
  });

  double? get averageRating {
    if (ratings == null) return null;
    final values = [
      ratings!['rating_chef'],
      ratings!['rating_delivery'],
      ratings!['rating_speed_chef'],
    ]
        .map((v) => double.tryParse(v?.toString() ?? ''))
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String get locationGroupKey =>
      addressLabel?.trim().isNotEmpty == true ? addressLabel! : _distanceGroupLabel();

  String _distanceGroupLabel() {
    if (distance == null) return 'قريب منك';
    final km = distance!.toStringAsFixed(1);
    return '($km km)';
  }

  factory ChefModel.fromJson(Map<String, dynamic> json) {
    return ChefModel(
      id: parseJsonInt(json['id']),
      name: json['name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      distance: double.tryParse(json['distance']?.toString() ?? ''),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      addressLabel: json['address']?.toString() ?? json['city']?.toString(),
      ratings: json['raties'] is Map<String, dynamic>
          ? json['raties'] as Map<String, dynamic>
          : null,
    );
  }
}
