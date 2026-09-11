import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/brand_header.dart';
import '../../../app/home_shell_scope.dart';
import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../core/formatting.dart';
import '../../auth/presentation/settings_sheet.dart';
import '../../dashboard/presentation/day_summary_section.dart';
import '../domain/fasting_protocol.dart';
import '../domain/fasting_session.dart';
import 'end_fast_sheet.dart';
import 'fast_complete_screen.dart';
import 'fasting_controller.dart';
import 'protocol_controller.dart';
import 'protocol_select_screen.dart';
import 'widgets/fasting_path.dart';

const _secondary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textSecondary,
);

class FastingHomeScreen extends ConsumerStatefulWidget {
  const FastingHomeScreen({super.key});

  @override
  ConsumerState<FastingHomeScreen> createState() => _FastingHomeScreenState();
}

class _FastingHomeScreenState extends ConsumerState<FastingHomeScreen>
    with WidgetsBindingObserver {
  var _actionInProgress = false;

  FastingController get _controller =>
      ref.read(fastingControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_controller.restore());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller.pauseTicker();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final protocol = ref.watch(selectedProtocolProvider);
    final fastingState = ref.watch(fastingControllerProvider);
    final now = ref.read(clockProvider).now();
    final session = fastingState.value;
    final active = session != null && session.status != FastingStatus.ended
        ? session
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BrandHeader(
                actionIcon: MambaIcons.settings,
                actionLabel: 'Settings',
                onAction: () => showSettingsSheet(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DayHeading(now: now, compact: active != null),
                    if (fastingState.isLoading && !fastingState.hasValue)
                      const _LoadingContent()
                    else if (fastingState.hasError && !fastingState.hasValue)
                      _ErrorContent(
                        onRetry: () => unawaited(_controller.restore()),
                      )
                    else if (active == null)
                      _IdleHero(
                        protocol: protocol,
                        now: now,
                        busy: _actionInProgress,
                        onStart: () => _run(_controller.start),
                        onChangeProtocol: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProtocolSelectScreen(),
                          ),
                        ),
                      )
                    else
                      _ActiveHero(
                        session: active,
                        now: now,
                        busy: _actionInProgress,
                        onPause: () => _run(_controller.pause),
                        onResume: () => _run(_controller.resume),
                        onEnd: () => _confirmEnd(active),
                      ),
                    const SizedBox(height: 20),
                    const DaySummarySection(),
                  ],
                ),
              ),
            ),
          ],
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

  Future<void> _confirmEnd(FastingSession session) async {
    if (_actionInProgress) return;
    final confirmed = await showEndFastSheet(
      context,
      session: session,
      now: ref.read(clockProvider).now(),
    );
    if (!confirmed || !mounted) return;

    await _run(_controller.end);
    final ended = ref.read(fastingControllerProvider).value;
    if (!mounted || ended?.status != FastingStatus.ended) return;

    final action = await Navigator.of(context).push<FastCompleteAction>(
      MaterialPageRoute(
        builder: (_) => FastCompleteScreen(
          session: ended!,
          now: ref.read(clockProvider).now(),
        ),
      ),
    );
    if (action == FastCompleteAction.logMeal && mounted) {
      HomeShellScope.maybeOf(context)?.selectTab(HomeShellScope.mealsTab);
    }
  }
}

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.now, required this.compact});

  final DateTime now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatGreeting(now),
            style: compact
                ? MambaTextStyles.screenTitle.copyWith(
                    fontSize: 20,
                    letterSpacing: -0.9,
                  )
                : MambaTextStyles.screenTitle,
          ),
          const SizedBox(height: 5),
          Text(formatDayLabel(now), style: _secondary.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Scales a large number down instead of overflowing.
class _FitWidth extends StatelessWidget {
  const _FitWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _IdleHero extends StatelessWidget {
  const _IdleHero({
    required this.protocol,
    required this.now,
    required this.busy,
    required this.onStart,
    required this.onChangeProtocol,
  });

  final FastingProtocol protocol;
  final DateTime now;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onChangeProtocol;

  @override
  Widget build(BuildContext context) {
    final finish = now.add(protocol.target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your next fast',
          style: _secondary.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        _FitWidth(
          child: Text(
            '${protocol.fastingHours.toString().padLeft(2, '0')}:00',
            style: MambaTextStyles.heroNumber,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${protocol.fastingHours}h fasting / ${protocol.eatingHours}h eating',
          style: _secondary.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Semantics(
          label:
              'Not fasting. Planned fasting duration '
              '${protocol.fastingHours} hours.',
          child: const ExcludeSemantics(
            child: FastingPath(progress: 0, idle: true),
          ),
        ),
        const SizedBox(height: 8),
        _TimeFacts(
          start: const _TimeFact(label: 'If you start', value: 'Now'),
          end: _TimeFact(
            label: 'You finish',
            value: formatClockTime(finish),
            suffix: formatRelativeDay(finish, now).toLowerCase(),
            alignEnd: true,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: busy ? null : onStart,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: const MambaIcon(
            MambaIcons.timer,
            size: 20,
            color: MambaColors.background,
          ),
          label: Text(busy ? 'Starting...' : 'Start fast'),
        ),
        const SizedBox(height: 2),
        Center(
          child: TextButton.icon(
            onPressed: busy ? null : onChangeProtocol,
            style: TextButton.styleFrom(
              foregroundColor: MambaColors.textSecondary,
            ),
            icon: const MambaIcon(
              MambaIcons.sliders,
              size: 18,
              color: MambaColors.textSecondary,
            ),
            label: const Text('Change protocol'),
          ),
        ),
      ],
    );
  }
}

class _ActiveHero extends StatelessWidget {
  const _ActiveHero({
    required this.session,
    required this.now,
    required this.busy,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  final FastingSession session;
  final DateTime now;
  final bool busy;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsedAt(now);
    final remaining = session.remainingAt(now);
    final reached = session.goalReachedAt(now);
    final paused = session.status == FastingStatus.paused;
    final progress = (elapsed.inMilliseconds / session.target.inMilliseconds)
        .clamp(0.0, 1.0);
    final endsAt = session.targetEndAt;
    final state = paused
        ? 'Paused'
        : reached
        ? 'Goal reached'
        : 'Fasting now';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                state,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: MambaColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: MambaColors.yellow,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              FastingProtocol.nameFor(session.protocolId, session.target),
              style: _secondary.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Time elapsed', style: _secondary.copyWith(fontSize: 11)),
        Semantics(
          label: 'Elapsed ${formatHoursMinutes(elapsed)}',
          excludeSemantics: true,
          child: _FitWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _hoursAndMinutes(elapsed),
                  style: MambaTextStyles.heroNumber,
                ),
                const SizedBox(width: 6),
                Text(
                  ':${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: _secondary.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (reached)
          Text(
            'You can end your fast whenever you’re ready.',
            style: _secondary.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: formatHoursMinutes(remaining)),
                TextSpan(
                  text: ' remaining',
                  style: _secondary.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MambaColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        const SizedBox(height: 8),
        Semantics(
          label:
              '${formatHoursMinutes(elapsed)} elapsed, '
              '${formatHoursMinutes(remaining)} remaining.',
          child: ExcludeSemantics(child: FastingPath(progress: progress)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).round()}% of ${session.target.inHours}h goal',
            style: _secondary.copyWith(fontSize: 11),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _TimeFacts(
          start: _TimeFact(
            label: 'Started',
            value: formatClockTime(session.startedAt),
            suffix: formatRelativeDay(session.startedAt, now),
            valueSize: 16,
            valueWeight: FontWeight.w600,
          ),
          end: _TimeFact(
            label: 'Ends',
            value: endsAt == null ? '—' : formatClockTime(endsAt),
            suffix: endsAt == null ? 'paused' : formatRelativeDay(endsAt, now),
            alignEnd: true,
            valueSize: 21,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: paused
                  ? FilledButton(
                      onPressed: busy ? null : onResume,
                      child: const Text('Resume'),
                    )
                  : ElevatedButton(
                      onPressed: busy ? null : onPause,
                      child: const Text('Pause'),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: reached && !paused
                  ? FilledButton(
                      onPressed: busy ? null : onEnd,
                      child: const Text('End fast'),
                    )
                  : ElevatedButton(
                      onPressed: busy ? null : onEnd,
                      child: const Text('End fast'),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your session saves whenever you finish.',
          textAlign: TextAlign.center,
          style: _secondary.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

/// Two time facts side by side: [start] on the left, [end] flush right.
class _TimeFacts extends StatelessWidget {
  const _TimeFacts({required this.start, required this.end});

  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: start),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: end),
        ),
      ],
    );
  }
}

class _TimeFact extends StatelessWidget {
  const _TimeFact({
    required this.label,
    required this.value,
    this.suffix,
    this.alignEnd = false,
    this.valueSize = 15,
    this.valueWeight = FontWeight.w700,
  });

  final String label;
  final String value;
  final String? suffix;
  final bool alignEnd;
  final double valueSize;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: _secondary.copyWith(fontSize: 11)),
        const SizedBox(height: 3),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: value),
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: _secondary.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: valueSize,
            fontWeight: valueWeight,
            color: MambaColors.textPrimary,
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

String _hoursAndMinutes(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}
