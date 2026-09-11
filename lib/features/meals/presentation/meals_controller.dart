import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../data/meal_repository.dart';
import '../domain/meal.dart';
import '../domain/meal_validator.dart';

/// Owns today's meals for the Meals screen.
///
/// Today is the local calendar day of the clock when the list loads. Every
/// change is saved first and the list is then read back from storage.
class MealsController extends AsyncNotifier<List<Meal>> {
  @override
  Future<List<Meal>> build() async {
    final repository = await ref.watch(mealRepositoryProvider.future);
    return repository.mealsOn(ref.read(clockProvider).now());
  }

  /// Adds a meal at the current time.
  Future<void> add({required String name, required int calories}) async {
    _requireValid(name, calories);
    final repository = await ref.read(mealRepositoryProvider.future);
    await repository.add(
      name: name.trim(),
      calories: calories,
      eatenAt: ref.read(clockProvider).now(),
    );
    await _reload(repository);
  }

  Future<void> edit(
    Meal meal, {
    required String name,
    required int calories,
  }) async {
    _requireValid(name, calories);
    final repository = await ref.read(mealRepositoryProvider.future);
    await repository.update(
      meal.copyWith(name: name.trim(), calories: calories),
    );
    await _reload(repository);
  }

  Future<void> delete(Meal meal) async {
    final repository = await ref.read(mealRepositoryProvider.future);
    await repository.delete(meal.id);
    await _reload(repository);
  }

  /// Reloads the list, moving it to the new day after midnight.
  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(mealRepositoryProvider.future);
      return repository.mealsOn(ref.read(clockProvider).now());
    });
  }

  Future<void> _reload(MealRepository repository) async {
    state = AsyncData(await repository.mealsOn(ref.read(clockProvider).now()));
  }

  /// The form checks the same rules. This keeps invalid meals out of storage
  /// if another caller skips the form.
  void _requireValid(String name, int calories) {
    final error =
        MealValidator.name(name) ?? MealValidator.calories('$calories');
    if (error != null) throw ArgumentError(error);
  }
}

/// Auto-disposed so the list reloads from storage the next time it is shown.
final mealsControllerProvider =
    AsyncNotifierProvider.autoDispose<MealsController, List<Meal>>(
      MealsController.new,
    );
