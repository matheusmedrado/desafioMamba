import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../fasting/data/completed_fast_repository.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../fasting/presentation/fasting_controller.dart';
import '../../meals/presentation/meals_controller.dart';
import '../data/calorie_limit_repository.dart';
import '../domain/day_summary.dart';

/// Owns the daily calorie limit.
class CalorieLimitController extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(calorieLimitRepositoryProvider).load();

  Future<void> change(int limit) async {
    await ref.read(calorieLimitRepositoryProvider).save(limit);
    state = AsyncData(limit);
  }
}

final calorieLimitControllerProvider =
    AsyncNotifierProvider<CalorieLimitController, int>(
      CalorieLimitController.new,
    );

/// Fasts that ended today, read again when the current fast starts or ends.
final todayCompletedFastsProvider =
    FutureProvider.autoDispose<List<FastingSession>>((ref) async {
      // The fasting controller emits every second for the ticker. Only a new
      // fast or a lifecycle change can change this list.
      ref.watch(
        fastingControllerProvider.select(
          (state) => (state.value?.id, state.value?.status),
        ),
      );
      final completed = await ref.watch(completedFastRepositoryProvider.future);
      return completed.endedOn(ref.read(clockProvider).now());
    });

/// Today's totals and goal status.
///
/// Recalculated whenever an input changes, including every fasting tick, so
/// the fasting time of a running fast stays current.
final todaySummaryProvider = Provider.autoDispose<AsyncValue<DaySummary>>((
  ref,
) {
  final meals = ref.watch(mealsControllerProvider);
  final completed = ref.watch(todayCompletedFastsProvider);
  final current = ref.watch(fastingControllerProvider);
  final limit = ref.watch(calorieLimitControllerProvider);

  for (final input in <AsyncValue<Object?>>[meals, completed, current, limit]) {
    if (input.hasError && !input.hasValue) {
      return AsyncError(input.error!, input.stackTrace ?? StackTrace.current);
    }
  }
  if (!meals.hasValue ||
      !completed.hasValue ||
      !current.hasValue ||
      !limit.hasValue) {
    return const AsyncLoading();
  }

  final now = ref.read(clockProvider).now();
  return AsyncData(
    DaySummary.calculate(
      day: now,
      now: now,
      meals: meals.requireValue,
      completedFasts: completed.requireValue,
      currentFast: current.value,
      calorieLimit: limit.requireValue,
    ),
  );
});
