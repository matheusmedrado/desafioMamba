/// Why an account action failed. The screen turns it into a message.
enum AuthFailure implements Exception {
  invalidCredentials,
  emailInUse,
  weakPassword,
  invalidEmail,
  tooManyAttempts,
  network,
  disabled,
  notEnabled,
  unknown;

  /// Maps a Firebase Auth error code.
  static AuthFailure fromCode(String code) => switch (code) {
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' => invalidCredentials,
    'email-already-in-use' => emailInUse,
    'weak-password' => weakPassword,
    'invalid-email' => invalidEmail,
    'too-many-requests' => tooManyAttempts,
    'network-request-failed' => network,
    'user-disabled' => disabled,
    'operation-not-allowed' => notEnabled,
    _ => unknown,
  };
}
