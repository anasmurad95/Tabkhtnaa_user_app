/// Carries registration OTP context through the post-register flow.
class RegisterSession {
  const RegisterSession({
    required this.countryCode,
    required this.mobile,
    required this.smsVerifyCode,
  });

  final String countryCode;
  final String mobile;
  final String smsVerifyCode;

  factory RegisterSession.fromSmsResponse({
    required String countryCode,
    required String mobile,
    required Map<String, dynamic> userJson,
  }) {
    return RegisterSession(
      countryCode: countryCode,
      mobile: mobile,
      smsVerifyCode: userJson['sms_verify']?.toString() ?? '',
    );
  }
}
