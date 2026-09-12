import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/auth/domain/login_validator.dart';

void main() {
  group('email', () {
    test('rejects empty input', () {
      for (final value in ['', '   ', null]) {
        expect(LoginValidator.email(value), LoginFieldError.emailRequired);
      }
    });

    test('rejects malformed addresses', () {
      for (final value in [
        'mamba',
        'mamba@',
        'mamba@site',
        'ma mba@site.com',
      ]) {
        expect(LoginValidator.email(value), LoginFieldError.emailInvalid);
      }
    });

    test('accepts a normal address with surrounding spaces', () {
      expect(LoginValidator.email(' user@example.com '), isNull);
    });
  });

  group('password', () {
    test('rejects empty input', () {
      for (final value in ['', null]) {
        expect(
          LoginValidator.password(value),
          LoginFieldError.passwordRequired,
        );
      }
    });

    test('requires the minimum length', () {
      expect(
        LoginValidator.password('1234567'),
        LoginFieldError.passwordTooShort,
      );
      expect(LoginValidator.password('12345678'), isNull);
    });

    test('a confirmation must match the password', () {
      expect(
        LoginValidator.confirmPassword('', 'password1'),
        LoginFieldError.confirmPasswordRequired,
      );
      expect(
        LoginValidator.confirmPassword('password2', 'password1'),
        LoginFieldError.passwordsDoNotMatch,
      );
      expect(LoginValidator.confirmPassword('password1', 'password1'), isNull);
    });
  });
}
