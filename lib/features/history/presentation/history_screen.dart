import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../core/formatting.dart';
import '../../dashboard/domain/day_summary.dart';
import '../../fasting/domain/fasting_protocol.dart';
import '../domain/history_day.dart';
import 'history_controller.dart';
import 'history_day_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A new day may have started while the app was in the background.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refresh() {
    unawaited(ref.read(historyControllerProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyControllerProvider);
    final now = ref.read(clockProvider).now();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 24,
        title: const Text('History'),
      ),
      body: switch (history) {
        AsyncData(:final value) when value.isEmpty => const _EmptyHistory(),
        AsyncData(:final value) => _HistoryList(days: value, now: now),
        AsyncError() => _HistoryError(onRetry: _refresh),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.days, required this.now});

  final List<HistoryDay> days;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    HistoryGroup? group;
    for (final day in days) {
      final dayGroup = historyGroupOf(day.day, now);
      if (dayGroup != group) {
        group = dayGroup;
        children.add(_GroupTitle(dayGroup));
      } else {
        children.add(const Divider());
      }
      children.add(_DayRow(day: day));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: children,
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.group);

  final HistoryGroup group;

  @override
  Widget build(BuildContext context) {
    final label = switch (group) {
      HistoryGroup.thisWeek => 'This week',
      HistoryGroup.lastWeek => 'Last week',
      HistoryGroup.earlier => 'Earlier',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final HistoryDay day;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = day.summary;
    final lastFast = day.fasts.isEmpty ? null : day.fasts.last;
    final calories = '${formatThousands(summary.calories)} kcal';

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => HistoryDayScreen(day: day)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _DateBadge(day.day),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lastFast == null
                        ? 'No fast'
                        : '${formatHoursMinutes(summary.fastingTime)} fast',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: lastFast == null
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: lastFast == null
                          ? MambaColors.textSecondary
                          : null,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastFast == null
                        ? calories
                        : '${FastingProtocol.nameFor(lastFast.protocolId, lastFast.target)} · $calories',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusDot(hasFast: lastFast != null, status: summary.status),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: MambaColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge(this.day);

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: MambaColors.surface,
        border: Border.all(color: MambaColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: textTheme.titleMedium?.copyWith(
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            formatWeekdayShort(day).toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              height: 1,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.hasFast, required this.status});

  final bool hasFast;
  final DayGoalStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = !hasFast
        ? (Icons.remove, 'No fast', MambaColors.textSecondary)
        : status == DayGoalStatus.within
        ? (Icons.check, 'Within goal', MambaColors.textPrimary)
        : (Icons.flag_outlined, 'Outside goal', MambaColors.textSecondary);

    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MambaColors.surfaceElevated,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: 28,
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MambaColors.purpleTint,
                borderRadius: BorderRadius.all(
                  Radius.circular(MambaRadius.large),
                ),
              ),
              child: SizedBox.square(
                dimension: 64,
                child: Icon(Icons.calendar_today_outlined, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nothing here yet',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed fasts and daily calories will show up here, '
            'one line per day.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: MambaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('We could not load your history.'),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
