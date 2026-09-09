import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/auth/domain/login_validator.dart';

void main() {
  group('email', () {
    test('rejects empty input', () {
      expect(LoginValidator.email(''), 'Enter your email.');
      expect(LoginValidator.email('   '), 'Enter your email.');
      expect(LoginValidator.email(null), 'Enter your email.');
    });

    test('rejects malformed addresses', () {
      expect(LoginValidator.email('mamba'), isNotNull);
      expect(LoginValidator.email('mamba@'), isNotNull);
      expect(LoginValidator.email('mamba@site'), isNotNull);
      expect(LoginValidator.email('ma mba@site.com'), isNotNull);
    });

    test('accepts a normal address with surrounding spaces', () {
      expect(LoginValidator.email(' user@example.com '), isNull);
    });
  });

  group('password', () {
    test('rejects empty input', () {
      expect(LoginValidator.password(''), 'Enter your password.');
      expect(LoginValidator.password(null), 'Enter your password.');
    });

    test('requires the minimum length', () {
      expect(LoginValidator.password('1234567'), isNotNull);
      expect(LoginValidator.password('12345678'), isNull);
    });
  });
}
