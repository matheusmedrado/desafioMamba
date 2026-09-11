import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/day_summary_section.dart';
import '../domain/fasting_protocol.dart';
import '../domain/fasting_session.dart';
import 'fasting_controller.dart';
import 'protocol_controller.dart';
import 'protocol_select_screen.dart';
import 'widgets/fasting_window_bar.dart';

/// Main signed-in screen for the fasting timer feature.
class FastingHomeScreen extends ConsumerStatefulWidget {
  const FastingHomeScreen({super.key});

  @override
  ConsumerState<FastingHomeScreen> createState() => _FastingHomeScreenState();
}

class _FastingHomeScreenState extends ConsumerState<FastingHomeScreen>
    with WidgetsBindingObserver {
  var _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(fastingControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.restore());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        controller.pauseTicker();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = ref.watch(authControllerProvider).value?.email ?? '';
    final protocol =
        ref.watch(protocolControllerProvider).value?.selected ??
        ProtocolSettings.defaults.selected;
    final fastingState = ref.watch(fastingControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                email: email,
                onLogout: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
              const SizedBox(height: 32),
              if (fastingState.isLoading && !fastingState.hasValue)
                const _LoadingContent()
              else if (fastingState.hasError && !fastingState.hasValue)
                _ErrorContent(
                  onRetry: () => unawaited(
                    ref.read(fastingControllerProvider.notifier).restore(),
                  ),
                )
              else
                _TimerContent(
                  session: fastingState.value,
                  protocol: protocol,
                  now: ref.read(clockProvider).now(),
                  actionInProgress: _actionInProgress,
                  onStart: () =>
                      _run(ref.read(fastingControllerProvider.notifier).start),
                  onPause: () =>
                      _run(ref.read(fastingControllerProvider.notifier).pause),
                  onResume: () =>
                      _run(ref.read(fastingControllerProvider.notifier).resume),
                  onEnd: () =>
                      _run(ref.read(fastingControllerProvider.notifier).end),
                  onChangeProtocol: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProtocolSelectScreen(),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const DaySummarySection(),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'All fasting data stays on this device.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the fast. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.email, required this.onLogout});

  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
              const SizedBox(height: 18),
              Text('Signed in as', style: textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(email, style: textTheme.titleMedium),
            ],
          ),
        ),
        IconButton(
          onPressed: onLogout,
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

class _TimerContent extends StatelessWidget {
  const _TimerContent({
    required this.session,
    required this.protocol,
    required this.now,
    required this.actionInProgress,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
    required this.onChangeProtocol,
  });

  final FastingSession? session;
  final FastingProtocol protocol;
  final DateTime now;
  final bool actionInProgress;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;
  final VoidCallback onChangeProtocol;

  @override
  Widget build(BuildContext context) {
    return session == null
        ? _ReadyToStart(
            protocol: protocol,
            actionInProgress: actionInProgress,
            onStart: onStart,
            onChangeProtocol: onChangeProtocol,
          )
        : _ActiveFast(
            session: session!,
            now: now,
            actionInProgress: actionInProgress,
            onStart: onStart,
            onPause: onPause,
            onResume: onResume,
            onEnd: onEnd,
            onChangeProtocol: onChangeProtocol,
          );
  }
}

class _ReadyToStart extends StatelessWidget {
  const _ReadyToStart({
    required this.protocol,
    required this.actionInProgress,
    required this.onStart,
    required this.onChangeProtocol,
  });

  final FastingProtocol protocol;
  final bool actionInProgress;
  final VoidCallback onStart;
  final VoidCallback onChangeProtocol;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ready when you are.', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Start a fast and let the timer keep your place through the day.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _ProtocolCard(protocol: protocol),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: actionInProgress ? null : onStart,
          icon: const Icon(Icons.play_arrow),
          label: Text(actionInProgress ? 'Starting...' : 'Start fast'),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: actionInProgress ? null : onChangeProtocol,
            child: const Text('Change protocol'),
          ),
        ),
      ],
    );
  }
}

class _ActiveFast extends StatelessWidget {
  const _ActiveFast({
    required this.session,
    required this.now,
    required this.actionInProgress,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
    required this.onChangeProtocol,
  });

  final FastingSession session;
  final DateTime now;
  final bool actionInProgress;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;
  final VoidCallback onChangeProtocol;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final elapsed = session.elapsedAt(now);
    final remaining = session.remainingAt(now);
    final goalReached = session.goalReachedAt(now);
    final progress = (elapsed.inMilliseconds / session.target.inMilliseconds)
        .clamp(0.0, 1.0);

    final status = switch (session.status) {
      FastingStatus.running when goalReached => 'Goal reached',
      FastingStatus.running => 'Fasting',
      FastingStatus.paused => 'Paused',
      FastingStatus.ended => 'Fast ended',
    };

    final message = switch (session.status) {
      FastingStatus.running when goalReached =>
        'You reached your planned fasting window.',
      FastingStatus.running => 'Keep going. You are on track.',
      FastingStatus.paused => 'Your elapsed time is frozen until you resume.',
      FastingStatus.ended when goalReached => 'Nice work completing your goal.',
      FastingStatus.ended => 'This fast ended before the planned window.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(status, style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(message, style: textTheme.bodyMedium),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _sessionProtocolName(session),
                      style: textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${session.target.inHours}h target',
                      style: textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Semantics(
                    label: 'Elapsed ${_formatDuration(elapsed)}',
                    child: Text(
                      _formatDuration(elapsed),
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 42,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(child: Text('Elapsed', style: textTheme.labelMedium)),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(MambaRadius.small),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: MambaColors.surfaceElevated,
                    color: goalReached
                        ? MambaColors.success
                        : MambaColors.purple,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimeStat(
                        label: 'Elapsed',
                        value: _formatDuration(elapsed),
                      ),
                    ),
                    Expanded(
                      child: _TimeStat(
                        label: 'Remaining',
                        value: _formatDuration(remaining),
                        alignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (session.status == FastingStatus.running)
          _RunningActions(
            disabled: actionInProgress,
            onPause: onPause,
            onEnd: onEnd,
          )
        else if (session.status == FastingStatus.paused)
          _PausedActions(
            disabled: actionInProgress,
            onResume: onResume,
            onEnd: onEnd,
          )
        else
          FilledButton.icon(
            onPressed: actionInProgress ? null : onStart,
            icon: const Icon(Icons.replay),
            label: Text(actionInProgress ? 'Starting...' : 'Start new fast'),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: actionInProgress ? null : onChangeProtocol,
            child: const Text('Change protocol for the next fast'),
          ),
        ),
      ],
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({required this.protocol});

  final FastingProtocol protocol;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(protocol.name, style: textTheme.titleLarge),
                const SizedBox(width: 10),
                Text(protocol.tag, style: textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(protocol.description, style: textTheme.bodySmall),
            const SizedBox(height: 16),
            FastingWindowBar(fastingHours: protocol.fastingHours),
          ],
        ),
      ),
    );
  }
}

class _RunningActions extends StatelessWidget {
  const _RunningActions({
    required this.disabled,
    required this.onPause,
    required this.onEnd,
  });

  final bool disabled;
  final VoidCallback onPause;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: disabled ? null : onPause,
            icon: const Icon(Icons.pause),
            label: const Text('Pause fast'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: disabled ? null : onEnd,
            icon: const Icon(Icons.stop),
            label: const Text('End fast'),
          ),
        ),
      ],
    );
  }
}

class _PausedActions extends StatelessWidget {
  const _PausedActions({
    required this.disabled,
    required this.onResume,
    required this.onEnd,
  });

  final bool disabled;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: disabled ? null : onResume,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume fast'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: disabled ? null : onEnd,
            icon: const Icon(Icons.stop),
            label: const Text('End fast'),
          ),
        ),
      ],
    );
  }
}

class _TimeStat extends StatelessWidget {
  const _TimeStat({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: 3),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('We could not load your fast.'),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

String _sessionProtocolName(FastingSession session) =>
    FastingProtocol.nameFor(session.protocolId, session.target);

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
