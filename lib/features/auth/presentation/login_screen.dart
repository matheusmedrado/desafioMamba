import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../domain/auth_failure.dart';
import '../domain/login_validator.dart';
import 'auth_controller.dart';
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
  String? _error;

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
      _error = null;
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
      _error = null;
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
      if (mounted) setState(() => _error = failure.message);
    } catch (_) {
      if (mounted) setState(() => _error = AuthFailure.unknown.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('Fast Tracker', style: textTheme.labelSmall),
                      const SizedBox(height: 40),
                      Text(
                        creating
                            ? 'Start your rhythm.'
                            : 'Back to your rhythm.',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        creating
                            ? 'Create an account to start tracking your fasts.'
                            : 'Your fasting plan, right where you left it.',
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          color: MambaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _FieldLabel('Email'),
                      TextFormField(
                        controller: _emailController,
                        validator: LoginValidator.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Password'),
                      TextFormField(
                        controller: _passwordController,
                        validator: LoginValidator.password,
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
                          hintText:
                              'At least ${LoginValidator.minPasswordLength} characters',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
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
                        const _FieldLabel('Confirm password'),
                        TextFormField(
                          controller: _confirmController,
                          validator: (value) => LoginValidator.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            hintText: 'Repeat your password',
                          ),
                        ),
                      ] else
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _submitting
                                ? null
                                : () {
                                    setState(() => _error = null);
                                    showPasswordResetSheet(
                                      context,
                                      email: _emailController.text,
                                    );
                                  },
                            child: const Text('Forgot password?'),
                          ),
                        ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _error!,
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
                                    ? 'Creating account...'
                                    : 'Signing in...')
                              : (creating ? 'Create account' : 'Log in'),
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
                                ? 'Already have an account?'
                                : 'New to Mamba?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: MambaColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _submitting ? null : _toggleMode,
                            child: Text(
                              creating ? 'Log in' : 'Create an account',
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
