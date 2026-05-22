class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.native,
    required this.rtl,
  });

  final String code;
  final String name;
  final String native;
  final bool rtl;

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code']?.toString() ?? 'ar',
      name: json['name']?.toString() ?? '',
      native: json['native']?.toString() ?? json['name']?.toString() ?? '',
      rtl: json['rtl'] == true || json['rtl'] == 1,
    );
  }
}
