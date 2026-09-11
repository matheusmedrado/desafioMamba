import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../fasting/presentation/protocol_controller.dart';
import '../domain/week_summary.dart';
import 'weekly_fasting_chart.dart';

class WeekView extends ConsumerWidget {
  const WeekView({super.key, required this.summary});

  final WeekSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final goalHours = ref.watch(selectedProtocolProvider).fastingHours;
    final days = summary.days;
    final average = summary.averageFast;
    final best = summary.bestDay;
    final within = summary.daysWithinGoal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          'Last 7 days',
          style: textTheme.headlineMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          formatDayRange(days.first.day, days.last.day),
          style: textTheme.bodyMedium?.copyWith(
            color: MambaColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text('Fasting hours per day', style: textTheme.titleSmall),
            ),
            const _LegendItem(color: MambaColors.purple, label: 'Goal reached'),
            const SizedBox(width: 12),
            const _LegendItem(color: MambaColors.surfaceHover, label: 'Short'),
          ],
        ),
        const SizedBox(height: 4),
        Text('Daily goal: ${goalHours}h', style: textTheme.labelSmall),
        const SizedBox(height: 8),
        WeeklyFastingChart(days: days, goalHours: goalHours),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCard(
                label: 'Average fast',
                value: average == null ? '—' : formatHoursMinutes(average),
                caption: 'per fast',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Goal completion',
                value: '$within/7',
                caption: '${(within / 7 * 100).round()}% of days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Best day',
                value: best == null
                    ? '—'
                    : formatHoursMinutes(best.fastingTime),
                caption: best == null
                    ? 'No fasts'
                    : '${formatWeekdayShort(best.day)} ${best.day.day}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You were within goal on $within of the last 7 days.',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(caption, style: textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
