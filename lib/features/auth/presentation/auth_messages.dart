import '../../../l10n/app_localizations.dart';
import '../domain/auth_failure.dart';
import '../domain/login_validator.dart';

/// Messages for the account errors that the domain reports as codes.
String authFailureMessage(AppLocalizations l10n, AuthFailure failure) {
  return switch (failure) {
    AuthFailure.invalidCredentials => l10n.authInvalidCredentials,
    AuthFailure.emailInUse => l10n.authEmailInUse,
    AuthFailure.weakPassword => l10n.authWeakPassword,
    AuthFailure.invalidEmail => l10n.authInvalidEmail,
    AuthFailure.tooManyAttempts => l10n.authTooManyAttempts,
    AuthFailure.network => l10n.authNetwork,
    AuthFailure.disabled => l10n.authDisabled,
    AuthFailure.notEnabled => l10n.authNotEnabled,
    AuthFailure.unknown => l10n.authUnknown,
  };
}

String? loginFieldMessage(AppLocalizations l10n, LoginFieldError? error) {
  return switch (error) {
    null => null,
    LoginFieldError.emailRequired => l10n.errorEmailRequired,
    LoginFieldError.emailInvalid => l10n.errorEmailInvalid,
    LoginFieldError.passwordRequired => l10n.errorPasswordRequired,
    LoginFieldError.passwordTooShort => l10n.errorPasswordTooShort(
      LoginValidator.minPasswordLength,
    ),
    LoginFieldError.confirmPasswordRequired =>
      l10n.errorConfirmPasswordRequired,
    LoginFieldError.passwordsDoNotMatch => l10n.errorPasswordsDoNotMatch,
  };
}
