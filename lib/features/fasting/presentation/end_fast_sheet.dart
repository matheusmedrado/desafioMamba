import 'package:flutter/material.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../domain/fasting_session.dart';

/// Asks before ending [session]. Returns true when the user confirms.
Future<bool> showEndFastSheet(
  BuildContext context, {
  required FastingSession session,
  required DateTime now,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => EndFastSheet(session: session, now: now),
  );
  return confirmed ?? false;
}

class EndFastSheet extends StatelessWidget {
  const EndFastSheet({super.key, required this.session, required this.now});

  static const confirmKey = Key('confirm-end-fast');

  final FastingSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reached = session.goalReachedAt(now);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('End this fast?', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Your session will be saved to History.',
              style: textTheme.bodyMedium?.copyWith(
                color: MambaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (!reached) ...[
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: MambaColors.surfaceElevated,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MambaIcon(
                        MambaIcons.alert,
                        size: 20,
                        color: MambaColors.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'You’re '),
                              TextSpan(
                                text: formatHoursMinutes(
                                  session.remainingAt(now),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: MambaColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' short of your ${session.target.inHours}h '
                                    'goal. Ending now marks today as '
                                    '“goal not reached”.',
                              ),
                            ],
                          ),
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Fasted so far', style: textTheme.bodyMedium),
                  ),
                  Text(
                    formatHoursMinutes(session.elapsedAt(now)),
                    style: textTheme.titleSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Keep fasting'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: confirmKey,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('End fast'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
