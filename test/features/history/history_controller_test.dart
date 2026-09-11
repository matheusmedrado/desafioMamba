import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/dashboard/domain/day_summary.dart';
import 'package:mamba_fast_tracker/features/dashboard/presentation/today_summary.dart';
import 'package:mamba_fast_tracker/features/fasting/data/completed_fast_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/history/presentation/history_controller.dart';
import 'package:mamba_fast_tracker/features/meals/data/meal_repository.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    database = await AppDatabase.open(databaseFactoryFfi, inMemoryDatabasePath);

    final meals = MealRepository(database);
    await meals.add(
      name: 'Pasta',
      calories: 1800,
      eatenAt: DateTime(2026, 9, 9, 13),
    );
    await meals.add(
      name: 'Toast',
      calories: 300,
      eatenAt: DateTime(2026, 9, 10, 8),
    );
    await CompletedFastRepository(database).save(
      FastingSession.start(
        id: 'fast-1',
        protocolId: '16:8',
        target: const Duration(hours: 16),
        startedAt: DateTime(2026, 9, 8, 20),
      ).endAt(DateTime(2026, 9, 9, 12, 30)),
    );
  });

  tearDown(() => database.close());

  ProviderContainer newContainer(FakeClock clock) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        databaseProvider.overrideWith((ref) => database),
      ],
    );
    addTearDown(container.dispose);
    container.listen(historyControllerProvider, (_, _) {});
    return container;
  }

  test('lists previous days from storage after a restart', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 18));

    for (final container in [newContainer(clock), newContainer(clock)]) {
      final [day] = await container.read(historyControllerProvider.future);
      expect(day.day, DateTime(2026, 9, 9));
      expect(day.summary.calories, 1800);
      expect(day.summary.fastingTime, const Duration(hours: 16, minutes: 30));
      expect(day.summary.status, DayGoalStatus.within);
    }
  });

  test('a lower calorie limit updates past statuses', () async {
    final container = newContainer(FakeClock(DateTime(2026, 9, 10, 18)));
    await container.read(historyControllerProvider.future);

    await container.read(calorieLimitControllerProvider.notifier).change(1500);

    final [day] = await container.read(historyControllerProvider.future);
    expect(day.summary.status, DayGoalStatus.outside);
  });

  test('refresh after midnight adds the day that just ended', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 23));
    final container = newContainer(clock);
    expect(
      await container.read(historyControllerProvider.future),
      hasLength(1),
    );

    clock.set(DateTime(2026, 9, 11, 7));
    await container.read(historyControllerProvider.notifier).refresh();

    final history = container.read(historyControllerProvider).requireValue;
    expect(history.map((day) => day.day), [
      DateTime(2026, 9, 10),
      DateTime(2026, 9, 9),
    ]);
  });
}
