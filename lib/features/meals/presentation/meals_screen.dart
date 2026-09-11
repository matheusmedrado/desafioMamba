import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../core/formatting.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final mealsState = ref.watch(mealsControllerProvider);
    final now = ref.read(clockProvider).now();

    // The tab shell has its own Scaffold. Without a messenger here, snack bars
    // are shown in that outer Scaffold and cover the Add meal button.
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          titleSpacing: 24,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Meals'),
              Text(formatDayLabel(now), style: textTheme.bodySmall),
            ],
          ),
        ),
        floatingActionButton: mealsState.hasValue
            ? FloatingActionButton.extended(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add meal'),
              )
            : null,
        body: mealsState.hasValue
            ? _MealList(meals: mealsState.value!, onEdit: _openForm)
            : mealsState.hasError
            ? _ErrorContent(
                onRetry: () => unawaited(
                  ref.read(mealsControllerProvider.notifier).refresh(),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _openForm([Meal? meal]) async {
    final result = await showMealFormSheet(context, meal: meal);
    if (!mounted || result == null) return;
    switch (result) {
      case MealFormResult.added:
        _showMessage('Meal added');
      case MealFormResult.updated:
        _showMessage('Meal updated');
      case MealFormResult.deleteRequested:
        await _confirmDelete(meal!);
    }
  }

  Future<void> _confirmDelete(Meal meal) async {
    final confirmed = await showDeleteMealSheet(context, meal);
    if (!mounted || confirmed == null) return;
    if (!confirmed) {
      await _openForm(meal);
      return;
    }
    try {
      await ref.read(mealsControllerProvider.notifier).delete(meal);
      if (mounted) _showMessage('Meal deleted');
    } catch (_) {
      if (mounted) _showMessage('Could not delete the meal. Try again.');
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
    final textTheme = Theme.of(context).textTheme;
    final count = meals.length;
    final meta = meals.isEmpty
        ? 'Nothing logged yet'
        : '$count ${count == 1 ? 'meal' : 'meals'} · '
              'last at ${formatClockTime(meals.last.eatenAt)}';

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
              'TODAY',
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
                    text: ' kcal',
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
    final textTheme = Theme.of(context).textTheme;
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
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: formatThousands(meal.calories)),
                  TextSpan(
                    text: ' kcal',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              style: textTheme.titleSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFeatures: tabular,
              ),
            ),
            IconButton(
              onPressed: onTap,
              tooltip: 'Edit ${meal.name}',
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: MambaColors.textSecondary,
              ),
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
              child: Icon(Icons.restaurant_outlined, size: 28),
            ),
          ),
          const SizedBox(height: 20),
          Text('No meals yet', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Log what you eat during your eating window.\n'
            'The time is recorded automatically.',
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('We could not load your meals.'),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
