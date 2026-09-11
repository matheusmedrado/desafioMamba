import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/brand_header.dart';
import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../core/formatting.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/settings_sheet.dart';
import '../domain/meal.dart';
import 'meal_sheets.dart';
import 'meals_controller.dart';

/// Today's meals with their calorie total.
class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen>
    with WidgetsBindingObserver {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The list covers one local day, which may have changed in the background.
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(mealsControllerProvider.notifier).refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealsState = ref.watch(mealsControllerProvider);
    final now = ref.read(clockProvider).now();

    // The tab shell has its own Scaffold. Without a messenger here, snack bars
    // are shown in that outer Scaffold and cover the Add meal button.
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        floatingActionButton: mealsState.hasValue
            ? FloatingActionButton.extended(
                onPressed: () => _openForm(),
                icon: const MambaIcon(
                  MambaIcons.plus,
                  color: MambaColors.background,
                ),
                label: Text(l10n.addMeal),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: l10n.mealsTab,
                subtitle: formatDayLabel(now),
                action: RoundIconButton(
                  icon: MambaIcons.settings,
                  label: l10n.settings,
                  onPressed: () => showSettingsSheet(context),
                ),
              ),
              Expanded(
                child: mealsState.hasValue
                    ? _MealList(meals: mealsState.value!, onEdit: _openForm)
                    : mealsState.hasError
                    ? _ErrorContent(
                        onRetry: () => unawaited(
                          ref.read(mealsControllerProvider.notifier).refresh(),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openForm([Meal? meal]) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showMealFormSheet(context, meal: meal);
    if (!mounted || result == null) return;
    switch (result) {
      case MealFormResult.added:
        _showMessage(l10n.mealAdded);
      case MealFormResult.updated:
        _showMessage(l10n.mealUpdated);
      case MealFormResult.deleteRequested:
        await _confirmDelete(meal!);
    }
  }

  Future<void> _confirmDelete(Meal meal) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDeleteMealSheet(context, meal);
    if (!mounted || confirmed == null) return;
    if (!confirmed) {
      await _openForm(meal);
      return;
    }
    try {
      await ref.read(mealsControllerProvider.notifier).delete(meal);
      if (mounted) _showMessage(l10n.mealDeleted);
    } catch (_) {
      if (mounted) _showMessage(l10n.mealDeleteError);
    }
  }

  void _showMessage(String message) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MealList extends StatelessWidget {
  const _MealList({required this.meals, required this.onEdit});

  final List<Meal> meals;
  final ValueChanged<Meal> onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Bottom padding keeps the last row clear of the Add meal button.
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 112),
      children: [
        _Summary(meals: meals),
        if (meals.isEmpty)
          const _EmptyState()
        else
          for (final (index, meal) in meals.indexed) ...[
            if (index > 0) const Divider(),
            _MealRow(meal: meal, onTap: () => onEdit(meal)),
          ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.meals});

  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final meta = meals.isEmpty
        ? l10n.nothingLoggedYet
        : l10n.mealsMeta(meals.length, formatClockTime(meals.last.eatenAt));

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MambaColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mealsToday,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: formatThousands(totalCalories(meals))),
                  TextSpan(
                    text: ' ${l10n.kcal}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: MambaColors.textSecondary,
                    ),
                  ),
                ],
              ),
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 44,
                letterSpacing: -1.3,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(meta, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.onTap});

  final Meal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const tabular = [FontFeature.tabularFigures()];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MambaRadius.small),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                formatClockTime(meal.eatenAt),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MambaColors.textSecondary,
                  fontFeatures: tabular,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                meal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: MambaColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: formatThousands(meal.calories)),
                  TextSpan(
                    text: ' ${l10n.kcal}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: MambaColors.textSecondary,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MambaColors.textPrimary,
                fontFeatures: tabular,
              ),
            ),
            const SizedBox(width: 12),
            RoundIconButton(
              icon: MambaIcons.pencil,
              label: l10n.editMealNamed(meal.name),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      child: Column(
        children: [
          const DecoratedBox(
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
                  MambaIcons.meals,
                  size: 28,
                  color: MambaColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.noMealsYet, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.noMealsBody,
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

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.couldNotLoadMeals),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
        ],
      ),
    );
  }
}
