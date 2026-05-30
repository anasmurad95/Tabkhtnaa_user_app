import 'dart:convert';

import '../../../../core/utils/json_parse.dart';

class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? countryCode;
  final String? profileImage;
  final String? accessToken;
  final String type;
  final String? gender;
  final String? dob;
  final String? defLang;
  final String? onlineStatus;
  final int? residenceCountryId;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    this.countryCode,
    this.profileImage,
    this.accessToken,
    this.type = 'client',
    this.gender,
    this.dob,
    this.defLang,
    this.onlineStatus,
    this.residenceCountryId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: parseJsonInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      countryCode: json['country_code']?.toString(),
      profileImage: json['profile_image']?.toString(),
      accessToken: json['access_token']?.toString(),
      type: json['type']?.toString() ?? 'client',
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      defLang: json['def_lang']?.toString(),
      onlineStatus: json['online_status']?.toString(),
      residenceCountryId: parseJsonIntOrNull(json['residence_country_id']),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? countryCode,
    String? profileImage,
    String? accessToken,
    String? gender,
    String? dob,
    String? defLang,
    String? onlineStatus,
    int? residenceCountryId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      countryCode: countryCode ?? this.countryCode,
      profileImage: profileImage ?? this.profileImage,
      accessToken: accessToken ?? this.accessToken,
      type: type,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      defLang: defLang ?? this.defLang,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      residenceCountryId: residenceCountryId ?? this.residenceCountryId,
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
        'gender': gender,
        'dob': dob,
        'def_lang': defLang,
        'online_status': onlineStatus,
        'residence_country_id': residenceCountryId,
      };

  Map<String, dynamic> toUpdatePayload() => {
        'name': name,
        if (email != null && email!.isNotEmpty) 'email': email,
        'mobile': mobile,
        'country_code': countryCode,
        'dob': dob,
        'gender': gender,
        if (defLang != null) 'def_lang': defLang,
        'residence_country_id': residenceCountryId ?? 111,
      };

  String toJsonString() => jsonEncode(toJson());

  static UserModel? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
