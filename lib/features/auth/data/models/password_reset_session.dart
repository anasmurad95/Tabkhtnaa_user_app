import '../../../../core/utils/json_parse.dart';

/// Carries forget-password response through OTP → reset-password screens.
class PasswordResetSession {
  const PasswordResetSession({
    required this.userId,
    required this.resetToken,
    required this.countryCode,
    required this.mobile,
  });

  final int userId;
  final String resetToken;
  final String countryCode;
  final String mobile;

  factory PasswordResetSession.fromJson(Map<String, dynamic> json) {
    return PasswordResetSession(
      userId: parseJsonInt(json['user_id']),
      resetToken: json['reset_password_token'] as String,
      countryCode: json['country_code']?.toString() ?? '962',
      mobile: json['mobile']?.toString() ?? '',
    );
  }
}
