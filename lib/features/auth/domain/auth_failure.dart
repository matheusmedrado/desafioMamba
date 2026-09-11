/// Why an account action failed, with a message the user can act on.
enum AuthFailure implements Exception {
  invalidCredentials('Email or password is incorrect.'),
  emailInUse('An account already exists for this email. Log in instead.'),
  weakPassword('Choose a stronger password.'),
  invalidEmail('That email does not look right.'),
  tooManyAttempts('Too many attempts. Try again in a few minutes.'),
  network('No connection. Check your internet and try again.'),
  disabled('This account has been disabled.'),
  notEnabled('Email sign-in is not available right now.'),
  unknown('Something went wrong. Try again.');

  const AuthFailure(this.message);

  final String message;

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
