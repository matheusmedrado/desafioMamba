import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../domain/week_summary.dart';

/// Bar chart of fasting hours for seven days, built from standard widgets.
class WeeklyFastingChart extends StatelessWidget {
  const WeeklyFastingChart({
    super.key,
    required this.days,
    required this.goalHours,
  });

  static const _maxHours = 24;
  static const _plotHeight = 160.0;
  static const _axisWidth = 32.0;
  static const _barWidth = 28.0;

  final List<WeekDay> days;
  final int goalHours;

  static double _offsetFor(num hours) =>
      hours.clamp(0, _maxHours) / _maxHours * _plotHeight;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return Semantics(
      container: true,
      label:
          'Fasting hours for each of the last seven days against the '
          '$goalHours-hour goal',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: _plotHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final hours in const [0, 8, 16, 24]) ...[
                    Positioned(
                      left: _axisWidth,
                      right: 0,
                      bottom: _offsetFor(hours),
                      child: Container(height: 1, color: MambaColors.border),
                    ),
                    Positioned(
                      left: 0,
                      bottom: _offsetFor(hours) - 7,
                      child: ExcludeSemantics(
                        child: Text('${hours}h', style: labelStyle),
                      ),
                    ),
                  ],
                  Positioned(
                    left: _axisWidth,
                    right: 0,
                    bottom: _offsetFor(goalHours),
                    child: const _DashedLine(),
                  ),
                  Positioned.fill(
                    left: _axisWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final day in days) Expanded(child: _Bar(day: day)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: _axisWidth),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  for (final day in days)
                    Expanded(
                      child: Text(
                        formatWeekdayShort(day.day),
                        textAlign: TextAlign.center,
                        style: labelStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day});

  final WeekDay day;

  @override
  Widget build(BuildContext context) {
    final hours = day.fastingTime.inMinutes / 60;
    final color = !day.hasFast
        ? MambaColors.surfaceElevated
        : day.fastingGoalReached
        ? MambaColors.purple
        : MambaColors.surfaceHover;
    final description = day.hasFast
        ? '${formatHoursMinutes(day.fastingTime)}'
              '${day.fastingGoalReached ? ', goal reached' : ', short'}'
        : 'no fast';

    return Semantics(
      container: true,
      label: '${formatWeekdayShort(day.day)}: $description',
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (day.hasFast) ...[
              Text(
                '${hours.round()}h',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: MambaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Container(
              width: WeeklyFastingChart._barWidth,
              height: day.hasFast
                  ? WeeklyFastingChart._offsetFor(hours).clamp(3.0, 160.0)
                  : 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    const dash = 4.0;
    const gap = 4.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / (dash + gap)).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              Container(
                width: dash,
                height: 1.5,
                color: MambaColors.textPrimary,
              ),
              const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}
