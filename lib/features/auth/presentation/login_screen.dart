import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_failure.dart';
import '../domain/login_validator.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'password_reset_sheet.dart';

/// Log in to an account, or create one with the same form.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  var _creatingAccount = false;
  var _autovalidate = AutovalidateMode.disabled;
  var _obscurePassword = true;
  var _submitting = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _formKey.currentState?.reset();
    setState(() {
      _creatingAccount = !_creatingAccount;
      _autovalidate = AutovalidateMode.disabled;
      _failure = null;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) {
      // Show errors and keep validating while the user fixes the fields.
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final auth = ref.read(authControllerProvider.notifier);
    try {
      if (_creatingAccount) {
        await auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await auth.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } catch (_) {
      if (mounted) setState(() => _failure = AuthFailure.unknown);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final creating = _creatingAccount;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 60,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/mamba-wordmark.webp',
                          width: 164,
                          semanticLabel: 'Mamba',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.brandTagline, style: textTheme.labelSmall),
                      const SizedBox(height: 40),
                      Text(
                        creating ? l10n.signUpTitle : l10n.loginTitle,
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        creating ? l10n.signUpSubtitle : l10n.loginSubtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          color: MambaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _FieldLabel(l10n.emailLabel),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) => loginFieldMessage(
                          l10n,
                          LoginValidator.email(value),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(hintText: l10n.emailHint),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(l10n.passwordLabel),
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) => loginFieldMessage(
                          l10n,
                          LoginValidator.password(value),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: creating
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: [
                          creating
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        onFieldSubmitted: creating ? null : (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: l10n.passwordHint(
                            LoginValidator.minPasswordLength,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            tooltip: _obscurePassword
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            icon: MambaIcon(
                              _obscurePassword
                                  ? MambaIcons.eye
                                  : MambaIcons.eyeOff,
                              size: 20,
                              color: MambaColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (creating) ...[
                        const SizedBox(height: 16),
                        _FieldLabel(l10n.confirmPasswordLabel),
                        TextFormField(
                          controller: _confirmController,
                          validator: (value) => loginFieldMessage(
                            l10n,
                            LoginValidator.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: l10n.confirmPasswordHint,
                          ),
                        ),
                      ] else
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _submitting
                                ? null
                                : () {
                                    setState(() => _failure = null);
                                    showPasswordResetSheet(
                                      context,
                                      email: _emailController.text,
                                    );
                                  },
                            child: Text(l10n.forgotPassword),
                          ),
                        ),
                      if (_failure case final failure?) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            authFailureMessage(l10n, failure),
                            style: textTheme.bodyMedium?.copyWith(
                              color: MambaColors.danger,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: creating ? 24 : 12),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: Text(
                          _submitting
                              ? (creating
                                    ? l10n.creatingAccount
                                    : l10n.signingIn)
                              : (creating ? l10n.createAccount : l10n.logIn),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            creating
                                ? l10n.alreadyHaveAnAccount
                                : l10n.newToMamba,
                            style: textTheme.bodyMedium?.copyWith(
                              color: MambaColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _submitting ? null : _toggleMode,
                            child: Text(
                              creating ? l10n.logIn : l10n.createAnAccount,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
