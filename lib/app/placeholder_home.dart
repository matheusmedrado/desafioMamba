import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/fasting/presentation/protocol_controller.dart';
import '../features/fasting/presentation/protocol_select_screen.dart';
import 'theme.dart';

/// Temporary signed-in screen until the dashboard exists.
class PlaceholderHome extends ConsumerWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final email = ref.watch(authControllerProvider).value?.email ?? '';
    final protocol = ref.watch(selectedProtocolProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/mamba-wordmark.webp',
                height: 32,
                semanticLabel: 'Mamba',
              ),
              const SizedBox(height: 8),
              Text(
                'FAST TRACKER',
                style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 40),
              Text('Signed in as', style: textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(email, style: textTheme.titleMedium),
              const SizedBox(height: 24),
              Text('Your protocol', style: textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                '${protocol.name}  ${protocol.tag}',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProtocolSelectScreen(),
                  ),
                ),
                child: const Text('Change protocol'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: const Text('Log out'),
              ),
              const SizedBox(height: 8),
              Text(
                'Fasting timer and meals arrive in the next issues.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: MambaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
