import 'package:flutter/material.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../../core/local_day.dart';
import '../../dashboard/domain/day_summary.dart';
import '../../fasting/domain/fasting_protocol.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../meals/domain/meal.dart';
import '../domain/history_day.dart';

const _tabular = [FontFeature.tabularFigures()];

const _secondary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textSecondary,
);

const _primary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textPrimary,
);

/// Read-only summary of one previous day.
class HistoryDayScreen extends StatelessWidget {
  const HistoryDayScreen({super.key, required this.day});

  final HistoryDay day;

  @override
  Widget build(BuildContext context) {
    final summary = day.summary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: formatDayLabel(day.day), showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                children: [
                  Text(
                    summary.status == DayGoalStatus.within
                        ? 'Within goal'
                        : 'Outside goal',
                    style: MambaTextStyles.screenTitle.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _statusReason(day),
                    style: _secondary.copyWith(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  if (day.fasts.isEmpty)
                    Text(
                      'No fast ended on this day.',
                      style: _secondary.copyWith(fontSize: 13),
                    )
                  else
                    for (final (index, fast) in day.fasts.indexed) ...[
                      if (index > 0) const SizedBox(height: 12),
                      _FastCard(fast: fast, day: day.day),
                    ],
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Meals',
                    trailing:
                        '${formatThousands(summary.calories)} / '
                        '${formatThousands(summary.calorieLimit)} kcal',
                  ),
                  if (day.meals.isEmpty)
                    Text(
                      'No meals logged.',
                      style: _secondary.copyWith(fontSize: 13),
                    )
                  else
                    for (final (index, meal) in day.meals.indexed) ...[
                      if (index > 0) const Divider(),
                      _MealRow(meal: meal),
                    ],
                ],
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title,
              style: _primary.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: _secondary.copyWith(fontSize: 12, fontFeatures: _tabular),
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
    final endedAt = fast.endedAt!;
    final elapsed = fast.elapsedAt(endedAt);
    final reached = fast.goalReachedAt(endedAt);
    final progress = (elapsed.inMilliseconds / fast.target.inMilliseconds)
        .clamp(0.0, 1.0);
    final difference = elapsed - fast.target;
    final big = _primary.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      height: 1,
      fontFeatures: _tabular,
    );
    final unit = _secondary.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MambaColors.surface,
        border: Border.all(color: MambaColors.border),
        borderRadius: BorderRadius.circular(MambaRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FASTING SESSION',
                        style: _secondary.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.96,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${elapsed.inHours}', style: big),
                            const SizedBox(width: 6),
                            Text('h', style: unit),
                            const SizedBox(width: 10),
                            Text(
                              elapsed.inMinutes
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0'),
                              style: big,
                            ),
                            const SizedBox(width: 6),
                            Text('m', style: unit),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _Chip(
                  icon: reached ? MambaIcons.check : MambaIcons.flag,
                  label: reached
                      ? 'Goal reached'
                      : '${(progress * 100).round()}% of target',
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: MambaColors.surfaceElevated,
                color: MambaColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _RangeText(
                    label: 'Started',
                    value: _timeOnDay(fast.startedAt, day),
                  ),
                ),
                _RangeText(label: 'Ended', value: formatClockTime(endedAt)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
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

class _RangeText extends StatelessWidget {
  const _RangeText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: MambaColors.textPrimary,
            ),
          ),
        ],
      ),
      style: _secondary.copyWith(fontSize: 12, fontFeatures: _tabular),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final MambaIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: MambaColors.surfaceElevated,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MambaIcon(
              icon,
              size: 14,
              color: MambaColors.textPrimary,
              strokeWidth: 2.2,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: _primary.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _secondary.copyWith(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: _primary.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
              fontFeatures: _tabular,
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                formatClockTime(meal.eatenAt),
                style: _secondary.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: _tabular,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                meal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _primary.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatThousands(meal.calories),
                  style: _primary.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFeatures: _tabular,
                  ),
                ),
                Text(
                  'kcal',
                  style: _secondary.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
