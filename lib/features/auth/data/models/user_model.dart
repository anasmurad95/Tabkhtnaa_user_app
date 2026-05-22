import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? countryCode;
  final String? profileImage;
  final String? accessToken;
  final String type;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    this.countryCode,
    this.profileImage,
    this.accessToken,
    this.type = 'client',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      countryCode: json['country_code']?.toString(),
      profileImage: json['profile_image']?.toString(),
      accessToken: json['access_token']?.toString(),
      type: json['type']?.toString() ?? 'client',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'mobile': mobile,
        'country_code': countryCode,
        'profile_image': profileImage,
        'access_token': accessToken,
        'type': type,
      };

  String toJsonString() => jsonEncode(toJson());

  static UserModel? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
