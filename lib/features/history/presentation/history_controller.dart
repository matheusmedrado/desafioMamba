import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../dashboard/presentation/today_summary.dart';
import '../../fasting/data/completed_fast_repository.dart';
import '../../meals/data/meal_repository.dart';
import '../domain/history_day.dart';

class HistoryController extends AsyncNotifier<List<HistoryDay>> {
  @override
  Future<List<HistoryDay>> build() async {
    return _load(await ref.watch(calorieLimitControllerProvider.future));
  }

  /// Reloads the list, for example when a new day started in the background.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () async => _load(await ref.read(calorieLimitControllerProvider.future)),
    );
  }

  Future<List<HistoryDay>> _load(int calorieLimit) async {
    final meals = await ref.read(mealRepositoryProvider.future);
    final fasts = await ref.read(completedFastRepositoryProvider.future);
    final now = ref.read(clockProvider).now();
    return buildHistory(
      now: now,
      meals: await meals.mealsBefore(now),
      fasts: await fasts.endedBefore(now),
      calorieLimit: calorieLimit,
    );
  }
}

final historyControllerProvider =
    AsyncNotifierProvider.autoDispose<HistoryController, List<HistoryDay>>(
      HistoryController.new,
    );
