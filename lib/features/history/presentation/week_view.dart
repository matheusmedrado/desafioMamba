import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final goalHours = ref.watch(selectedProtocolProvider).fastingHours;
    final days = summary.days;
    final average = summary.averageFast;
    final best = summary.bestDay;
    final within = summary.daysWithinGoal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(l10n.last7Days, style: MambaTextStyles.screenTitle),
        const SizedBox(height: 4),
        Text(
          formatDayRange(days.first.day, days.last.day),
          style: _secondary.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              l10n.fastingHoursPerDay,
              style: const TextStyle(
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
                _LegendItem(
                  color: MambaColors.purple,
                  label: l10n.legendGoalReached,
                ),
                _LegendItem(
                  color: MambaColors.surfaceHover,
                  label: l10n.legendShort,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.dailyGoal(goalHours),
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
                  label: l10n.averageFast,
                  value: average == null ? '—' : formatHoursMinutes(average),
                  caption: l10n.perFast,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: l10n.goalCompletion,
                  value: l10n.goalCompletionValue(within),
                  caption: l10n.percentOfDays((within / 7 * 100).round()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: l10n.bestDay,
                  value: best == null
                      ? '—'
                      : formatHoursMinutes(best.fastingTime),
                  caption: best == null
                      ? l10n.noFasts
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
                l10n.withinGoalOnDays(within),
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
