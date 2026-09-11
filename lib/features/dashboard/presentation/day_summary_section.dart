import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(todaySummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.yourDay,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MambaColors.textPrimary,
                ),
              ),
            ),
            if (summary.value case final value?) _StatusChip(value.status),
          ],
        ),
        const SizedBox(height: 8),
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
          const SizedBox(height: 90),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final DayGoalStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, label) = switch (status) {
      DayGoalStatus.within => (MambaIcons.check, l10n.withinGoal),
      DayGoalStatus.outside => (MambaIcons.flag, l10n.outsideGoal),
      DayGoalStatus.inProgress => (MambaIcons.clock, l10n.inProgress),
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
            MambaIcon(icon, size: 14, color: MambaColors.textPrimary),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: MambaColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(MambaRadius.medium)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Stat(
                      label: l10n.calories,
                      value: formatThousands(summary.calories),
                      unit: l10n.calorieLimitUnit(
                        formatThousands(summary.calorieLimit),
                      ),
                      onTap: onChangeLimit,
                      tapLabel: l10n.changeCalorieLimit,
                    ),
                  ),
                  const VerticalDivider(width: 33),
                  Expanded(
                    child: _Stat(
                      label: l10n.fastedToday,
                      value: formatHoursMinutes(summary.fastingTime),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _statusMessage(l10n, summary),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
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
    final tappable = onTap != null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  letterSpacing: 0.24,
                  color: MambaColors.textSecondary,
                ),
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 4),
              const MambaIcon(
                MambaIcons.pencil,
                size: 12,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: MambaColors.textSecondary,
                  ),
                ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.15,
            color: MambaColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
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
        child: content,
      ),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(child: Text(l10n.couldNotLoadDay)),
        TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
      ],
    );
  }
}

String _statusMessage(AppLocalizations l10n, DaySummary summary) {
  return switch (summary.status) {
    DayGoalStatus.within => l10n.dayWithinMessage,
    DayGoalStatus.inProgress => l10n.dayInProgressMessage(
      formatThousands(summary.calorieLimit),
    ),
    DayGoalStatus.outside when !summary.caloriesWithinLimit =>
      l10n.dayOverCaloriesMessage(
        formatThousands(summary.calories - summary.calorieLimit),
      ),
    DayGoalStatus.outside => l10n.dayFastShortMessage,
  };
}
