import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final email = ref.watch(authControllerProvider).value?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Signed in as', style: textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(email, style: textTheme.titleMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final auth = ref.read(authControllerProvider.notifier);
                Navigator.of(context).pop();
                unawaited(auth.logout());
              },
              icon: const MambaIcon(MambaIcons.logOut, size: 20),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
