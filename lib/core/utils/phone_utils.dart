/// Normalizes phone values to match Laravel auth validators.
class PhoneUtils {
  PhoneUtils._();

  /// Strips non-digits and leading zeros from country codes (`+962`, `00962` → `962`).
  static String normalizeCountryCode(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    return digits.replaceFirst(RegExp(r'^0+'), '');
  }

  /// Strips leading zeros from mobile numbers (`079600135` → `79600135`).
  static String normalizeMobile(String mobile) {
    return mobile.trim().replaceFirst(RegExp(r'^0+'), '');
  }
}
