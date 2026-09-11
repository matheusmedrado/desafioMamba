import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../meals/presentation/meals_controller.dart';
import '../domain/day_summary.dart';
import 'calorie_limit_sheet.dart';
import 'today_summary.dart';

/// "Your day" on the Today screen: calories against the limit, fasting time,
/// and whether the day is within goal.
class DaySummarySection extends ConsumerStatefulWidget {
  const DaySummarySection({super.key});

  @override
  ConsumerState<DaySummarySection> createState() => _DaySummarySectionState();
}

class _DaySummarySectionState extends ConsumerState<DaySummarySection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Today may have become a new day while the app was in the background.
    if (state == AppLifecycleState.resumed) _reloadDay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _reloadDay() {
    ref.invalidate(todayCompletedFastsProvider);
    unawaited(ref.read(mealsControllerProvider.notifier).refresh());
  }

  void _retry() {
    ref.invalidate(calorieLimitControllerProvider);
    _reloadDay();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = ref.watch(todaySummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Your day', style: textTheme.titleSmall)),
            if (summary.value case final value?) _StatusChip(value.status),
          ],
        ),
        const SizedBox(height: 12),
        if (summary.value case final value?)
          _SummaryContent(
            summary: value,
            onChangeLimit: () => showCalorieLimitSheet(
              context,
              currentLimit: value.calorieLimit,
            ),
          )
        else if (summary.hasError)
          _SummaryError(onRetry: _retry)
        else
          const SizedBox(height: 72),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final DayGoalStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (status) {
      DayGoalStatus.within => (Icons.check, 'Within goal'),
      DayGoalStatus.outside => (Icons.flag_outlined, 'Outside goal'),
      DayGoalStatus.inProgress => (Icons.schedule, 'In progress'),
    };

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: MambaColors.surfaceElevated,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: MambaColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: MambaColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary, required this.onChangeLimit});

  final DaySummary summary;
  final VoidCallback onChangeLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Stat(
                label: 'Calories',
                value: formatThousands(summary.calories),
                unit: '/ ${formatThousands(summary.calorieLimit)} kcal',
                onTap: onChangeLimit,
                tapLabel: 'Change calorie limit',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _Stat(
                label: 'Fasted today',
                value: formatHoursMinutes(summary.fastingTime),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _statusMessage(summary),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.unit,
    this.onTap,
    this.tapLabel,
  });

  final String label;
  final String value;
  final String? unit;
  final VoidCallback? onTap;
  final String? tapLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tappable = onTap != null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: textTheme.labelSmall),
            if (tappable) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.edit_outlined,
                size: 14,
                color: MambaColors.textSecondary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: value),
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: textTheme.labelMedium?.copyWith(letterSpacing: 0),
                ),
            ],
          ),
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 25,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    if (!tappable) return content;
    return Tooltip(
      message: tapLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MambaRadius.small),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text('We could not load your day.')),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}

String _statusMessage(DaySummary summary) {
  final limit = formatThousands(summary.calorieLimit);
  return switch (summary.status) {
    DayGoalStatus.within =>
      'Calories within your limit and fasting goal reached.',
    DayGoalStatus.inProgress =>
      'Stay within $limit kcal and reach your fasting goal.',
    DayGoalStatus.outside when !summary.caloriesWithinLimit =>
      'Over your calorie limit by '
          '${formatThousands(summary.calories - summary.calorieLimit)} kcal.',
    DayGoalStatus.outside => 'Today\'s fast ended before its goal.',
  };
}
