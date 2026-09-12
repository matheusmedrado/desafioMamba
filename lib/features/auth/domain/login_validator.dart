/// What is wrong with a login field. The screen turns it into a message.
enum LoginFieldError {
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
  confirmPasswordRequired,
  passwordsDoNotMatch,
}

/// Form rules for the login screen.
abstract final class LoginValidator {
  static const minPasswordLength = 8;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static LoginFieldError? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return LoginFieldError.emailRequired;
    if (!_emailPattern.hasMatch(text)) return LoginFieldError.emailInvalid;
    return null;
  }

  static LoginFieldError? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return LoginFieldError.passwordRequired;
    if (text.length < minPasswordLength) {
      return LoginFieldError.passwordTooShort;
    }
    return null;
  }

  static LoginFieldError? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return LoginFieldError.confirmPasswordRequired;
    }
    if (value != password) return LoginFieldError.passwordsDoNotMatch;
    return null;
  }
}
