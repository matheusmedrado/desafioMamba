import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../l10n/app_localizations.dart';
import '../../fasting/data/fasting_notification_service.dart';
import 'auth_controller.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const SettingsSheet(),
  );
}

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final email = ref.watch(authControllerProvider).value?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settings, style: textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(l10n.signedInAs, style: textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(email, style: textTheme.titleMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final auth = ref.read(authControllerProvider.notifier);
                final notifications = ref.read(
                  fastingNotificationServiceProvider,
                );
                Navigator.of(context).pop();
                unawaited(
                  auth.signOut().then((_) => notifications.cancelAll()),
                );
              },
              icon: const MambaIcon(MambaIcons.logOut, size: 20),
              label: Text(l10n.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
