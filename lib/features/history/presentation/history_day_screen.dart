import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../../core/local_day.dart';
import '../../dashboard/domain/day_summary.dart';
import '../../fasting/domain/fasting_protocol.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../meals/domain/meal.dart';
import '../domain/history_day.dart';

/// Read-only summary of one previous day.
class HistoryDayScreen extends StatelessWidget {
  const HistoryDayScreen({super.key, required this.day});

  final HistoryDay day;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = day.summary;

    return Scaffold(
      appBar: AppBar(title: Text(formatDayLabel(day.day))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            summary.status == DayGoalStatus.within
                ? 'Within goal'
                : 'Outside goal',
            style: textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            _statusReason(day),
            style: textTheme.bodyMedium?.copyWith(
              color: MambaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: 'Fasting',
            trailing: day.fasts.isEmpty
                ? null
                : formatHoursMinutes(summary.fastingTime),
          ),
          if (day.fasts.isEmpty)
            Text('No fast ended on this day.', style: textTheme.bodySmall)
          else
            for (final (index, fast) in day.fasts.indexed) ...[
              if (index > 0) const SizedBox(height: 12),
              _FastCard(fast: fast, day: day.day),
            ],
          const SizedBox(height: 28),
          _SectionTitle(
            title: 'Meals',
            trailing:
                '${formatThousands(summary.calories)} / '
                '${formatThousands(summary.calorieLimit)} kcal',
          ),
          if (day.meals.isEmpty)
            Text('No meals logged.', style: textTheme.bodySmall)
          else
            for (final (index, meal) in day.meals.indexed) ...[
              if (index > 0) const Divider(),
              _MealRow(meal: meal),
            ],
        ],
      ),
    );
  }
}

String _statusReason(HistoryDay day) {
  final summary = day.summary;
  if (summary.status == DayGoalStatus.within) {
    return 'Calories within the limit and a fast reached its goal.';
  }
  final reasons = [
    if (!summary.caloriesWithinLimit)
      'over the calorie limit by '
          '${formatThousands(summary.calories - summary.calorieLimit)} kcal',
    if (!summary.fastingGoalReached)
      day.fasts.isEmpty ? 'no fast ended' : 'no fast reached its goal',
  ];
  final text = reasons.join(' and ');
  return '${text[0].toUpperCase()}${text.substring(1)}.';
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: textTheme.titleSmall)),
          if (trailing != null)
            Text(
              trailing!,
              style: textTheme.labelMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _FastCard extends StatelessWidget {
  const _FastCard({required this.fast, required this.day});

  final FastingSession fast;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final endedAt = fast.endedAt!;
    final elapsed = fast.elapsedAt(endedAt);
    final reached = fast.goalReachedAt(endedAt);
    final progress = (elapsed.inMilliseconds / fast.target.inMilliseconds)
        .clamp(0.0, 1.0);
    final difference = elapsed - fast.target;
    const tabular = [FontFeature.tabularFigures()];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatHoursMinutes(elapsed),
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      fontFeatures: tabular,
                    ),
                  ),
                ),
                _Chip(
                  reached
                      ? 'Goal reached'
                      : '${(progress * 100).round()}% of target',
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(MambaRadius.small),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: MambaColors.surfaceElevated,
                color: reached ? MambaColors.success : MambaColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started ${_timeOnDay(fast.startedAt, day)}',
                  style: textTheme.bodySmall,
                ),
                Text(
                  'Ended ${formatClockTime(endedAt)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _Fact(
                  label: 'Protocol',
                  value: FastingProtocol.nameFor(fast.protocolId, fast.target),
                ),
                _Fact(label: 'Target', value: '${fast.target.inHours}h'),
                _Fact(
                  label: 'Result',
                  value:
                      '${difference.isNegative ? '−' : '+'}'
                      '${formatHoursMinutes(difference.abs())}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _timeOnDay(DateTime time, DateTime day) => isOnLocalDay(time, day)
    ? formatClockTime(time)
    : '${formatClockTime(time)} ${formatWeekdayShort(time)}';

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: MambaColors.surfaceElevated,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: MambaColors.textPrimary),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const tabular = [FontFeature.tabularFigures()];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              formatClockTime(meal.eatenAt),
              style: textTheme.labelMedium?.copyWith(fontFeatures: tabular),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              meal.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${formatThousands(meal.calories)} kcal',
            style: textTheme.titleSmall?.copyWith(fontFeatures: tabular),
          ),
        ],
      ),
    );
  }
}
