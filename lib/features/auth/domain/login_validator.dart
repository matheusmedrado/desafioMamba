/// Form rules for the login screen. Returns an error message or null.
abstract final class LoginValidator {
  static const minPasswordLength = 8;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your email.';
    if (!_emailPattern.hasMatch(text)) return 'That email does not look right.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Enter your password.';
    if (text.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Repeat your password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }
}
