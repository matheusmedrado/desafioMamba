import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../core/formatting.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/profile_button.dart';
import '../../dashboard/domain/day_summary.dart';
import '../../fasting/domain/fasting_protocol.dart';
import '../domain/history_day.dart';
import '../domain/week_summary.dart';
import 'history_controller.dart';
import 'history_day_screen.dart';
import 'week_view.dart';

enum _HistoryView { days, week }

const _secondary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textSecondary,
);

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with WidgetsBindingObserver {
  var _view = _HistoryView.days;

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
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(historyControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.historyTab, action: const ProfileButton()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: _ViewSwitch(
                selected: _view,
                onChanged: (view) => setState(() => _view = view),
              ),
            ),
            Expanded(
              child: switch (history) {
                AsyncData(:final value) => _content(value),
                AsyncError() => _HistoryError(onRetry: _refresh),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(List<HistoryDay> days) {
    final now = ref.read(clockProvider).now();
    final week = WeekSummary.fromHistory(days, now);
    return switch (_view) {
      _HistoryView.week => WeekView(summary: week),
      _HistoryView.days when days.isEmpty => const _EmptyHistory(),
      _HistoryView.days => _HistoryList(days: days, week: week, now: now),
    };
  }
}

class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({required this.selected, required this.onChanged});

  final _HistoryView selected;
  final ValueChanged<_HistoryView> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MambaColors.surfaceElevated,
        border: Border.all(color: MambaColors.border),
        borderRadius: BorderRadius.circular(MambaRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ViewTab(
                label: l10n.days,
                selected: selected == _HistoryView.days,
                onTap: () => onChanged(_HistoryView.days),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ViewTab(
                label: l10n.week,
                selected: selected == _HistoryView.week,
                onTap: () => onChanged(_HistoryView.week),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewTab extends StatelessWidget {
  const _ViewTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? MambaColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(MambaRadius.small),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MambaRadius.small),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? MambaColors.textPrimary
                      : MambaColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.days,
    required this.week,
    required this.now,
  });

  final List<HistoryDay> days;
  final WeekSummary week;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[_WeekHeader(week)];
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

class _WeekHeader extends StatelessWidget {
  const _WeekHeader(this.week);

  final WeekSummary week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final average = week.averageFast;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MambaColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        child: Row(
          children: [
            Expanded(
              child: _HeaderStat(
                label: l10n.last7Days,
                value: '${week.daysWithinGoal}',
                unit: l10n.goalsOutOfSeven,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _HeaderStat(
                label: l10n.averageFast,
                value: average == null ? '—' : formatHoursMinutes(average),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _secondary.copyWith(fontSize: 12)),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: value),
              if (unit != null)
                TextSpan(
                  text: unit,
                  style: _secondary.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
            height: 1.15,
            color: MambaColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.group);

  final HistoryGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (group) {
      HistoryGroup.thisWeek => l10n.thisWeek,
      HistoryGroup.lastWeek => l10n.lastWeek,
      HistoryGroup.earlier => l10n.earlier,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Text(
        label,
        style: _secondary.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.96,
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final HistoryDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = day.summary;
    final lastFast = day.fasts.isEmpty ? null : day.fasts.last;
    final calories = formatThousands(summary.calories);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => HistoryDayScreen(day: day)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
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
                          ? l10n.noFast
                          : l10n.fastOfDuration(
                              formatHoursMinutes(summary.fastingTime),
                            ),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: lastFast == null
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: lastFast == null
                            ? MambaColors.textSecondary
                            : MambaColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lastFast == null
                          ? l10n.kcalWithValue(calories)
                          : l10n.protocolAndCalories(
                              FastingProtocol.nameFor(
                                lastFast.protocolId,
                                lastFast.target,
                              ),
                              calories,
                            ),
                      style: _secondary.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusDot(hasFast: lastFast != null, status: summary.status),
              const SizedBox(width: 8),
              const MambaIcon(
                MambaIcons.chevronRight,
                size: 18,
                color: MambaColors.textSecondary,
              ),
            ],
          ),
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
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.34,
              height: 1,
              color: MambaColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            formatWeekdayShort(day).toUpperCase(),
            style: _secondary.copyWith(
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
    final l10n = AppLocalizations.of(context)!;
    final (icon, label, color) = !hasFast
        ? (MambaIcons.minus, l10n.noFast, MambaColors.textSecondary)
        : status == DayGoalStatus.within
        ? (MambaIcons.check, l10n.withinGoal, MambaColors.textPrimary)
        : (MambaIcons.flag, l10n.outsideGoal, MambaColors.textSecondary);

    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MambaColors.surfaceElevated,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: 28,
          child: Center(
            child: MambaIcon(icon, size: 15, color: color, strokeWidth: 2.4),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                child: Center(
                  child: MambaIcon(
                    MambaIcons.calendar,
                    size: 28,
                    color: MambaColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.nothingHereYet,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.historyEmptyBody,
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.couldNotLoadHistory),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
        ],
      ),
    );
  }
}
