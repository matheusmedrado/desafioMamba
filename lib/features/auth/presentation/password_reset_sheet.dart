import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_failure.dart';
import '../domain/login_validator.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';

/// Asks for an email and sends a password reset link to it.
Future<void> showPasswordResetSheet(
  BuildContext context, {
  required String email,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final sentMessage = AppLocalizations.of(context)!.resetLinkSent;
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PasswordResetSheet(initialEmail: email),
  );
  if (sent ?? false) {
    messenger.showSnackBar(SnackBar(content: Text(sentMessage)));
  }
}

class PasswordResetSheet extends ConsumerStatefulWidget {
  const PasswordResetSheet({super.key, required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<PasswordResetSheet> createState() => _PasswordResetSheetState();
}

class _PasswordResetSheetState extends ConsumerState<PasswordResetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail.trim(),
  );

  var _sending = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _failure = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(_emailController.text);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } catch (_) {
      if (mounted) setState(() => _failure = AuthFailure.unknown);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.resetPasswordTitle, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l10n.resetPasswordBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: MambaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                validator: (value) =>
                    loginFieldMessage(l10n, LoginValidator.email(value)),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _send(),
                decoration: InputDecoration(hintText: l10n.emailHint),
              ),
              if (_failure case final failure?) ...[
                const SizedBox(height: 12),
                Text(
                  authFailureMessage(l10n, failure),
                  style: textTheme.bodyMedium?.copyWith(
                    color: MambaColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? l10n.sending : l10n.sendResetLink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
