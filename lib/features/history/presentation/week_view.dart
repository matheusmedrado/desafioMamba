import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../fasting/presentation/protocol_controller.dart';
import '../domain/week_summary.dart';
import 'weekly_fasting_chart.dart';

const _secondary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textSecondary,
);

class WeekView extends ConsumerWidget {
  const WeekView({super.key, required this.summary});

  final WeekSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalHours = ref.watch(selectedProtocolProvider).fastingHours;
    final days = summary.days;
    final average = summary.averageFast;
    final best = summary.bestDay;
    final within = summary.daysWithinGoal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        const Text('Last 7 days', style: MambaTextStyles.screenTitle),
        const SizedBox(height: 4),
        Text(
          formatDayRange(days.first.day, days.last.day),
          style: _secondary.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 20),
        const Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              'Fasting hours per day',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: MambaColors.textPrimary,
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _LegendItem(color: MambaColors.purple, label: 'Goal reached'),
                _LegendItem(color: MambaColors.surfaceHover, label: 'Short'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Daily goal: ${goalHours}h',
          style: _secondary.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        WeeklyFastingChart(days: days, goalHours: goalHours),
        const SizedBox(height: 24),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Average fast',
                  value: average == null ? '—' : formatHoursMinutes(average),
                  caption: 'per fast',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Goal completion',
                  value: '$within/7',
                  caption: '${(within / 7 * 100).round()}% of days',
                ),
              ),
              const SizedBox(width: 8),
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
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: MambaIcon(
                MambaIcons.check,
                size: 18,
                color: MambaColors.yellow,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You were within goal on $within of the last 7 days.',
                style: _secondary.copyWith(fontSize: 13, height: 1.45),
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
        Text(label, style: _secondary.copyWith(fontSize: 12)),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MambaColors.surface,
        border: Border.all(color: MambaColors.border),
        borderRadius: BorderRadius.circular(MambaRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Two-line labels keep every value on the same row.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 35),
              child: Text(label, style: _secondary.copyWith(fontSize: 12)),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.36,
                height: 1.15,
                color: MambaColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(caption, style: _secondary.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
