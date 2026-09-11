import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/auth/domain/auth_failure.dart';

void main() {
  test('maps Firebase error codes to failures', () {
    const expected = {
      'invalid-credential': AuthFailure.invalidCredentials,
      'wrong-password': AuthFailure.invalidCredentials,
      'user-not-found': AuthFailure.invalidCredentials,
      'email-already-in-use': AuthFailure.emailInUse,
      'weak-password': AuthFailure.weakPassword,
      'too-many-requests': AuthFailure.tooManyAttempts,
      'network-request-failed': AuthFailure.network,
      'operation-not-allowed': AuthFailure.notEnabled,
      'something-new': AuthFailure.unknown,
    };

    for (final MapEntry(:key, :value) in expected.entries) {
      expect(AuthFailure.fromCode(key), value, reason: key);
    }
  });

  test('sign in does not reveal whether an email has an account', () {
    expect(
      AuthFailure.fromCode('user-not-found'),
      AuthFailure.fromCode('wrong-password'),
    );
  });
}
