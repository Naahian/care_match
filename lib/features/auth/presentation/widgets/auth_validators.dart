abstract final class AuthValidators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
        ? null
        : 'Enter a valid email address.';
  }

  static String? password(String? value) =>
      value == null || value.isEmpty ? 'Enter your password.' : null;

  static String? newPassword(String? value) =>
      (value?.length ?? 0) < 6 ? 'Use at least 6 characters.' : null;

  static String? name(String? value) =>
      value == null || value.trim().isEmpty ? 'Enter your full name.' : null;

  static String? phone(String value) =>
      RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(value)
      ? null
      : 'Enter a valid phone number.';
}
