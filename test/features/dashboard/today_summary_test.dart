import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:mamba_fast_tracker/features/dashboard/domain/day_summary.dart';
import 'package:mamba_fast_tracker/features/dashboard/presentation/today_summary.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_controller.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/meals_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../fasting/fake_fasting_notification_service.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    database = await AppDatabase.open(databaseFactoryFfi, inMemoryDatabasePath);
  });

  tearDown(() => database.close());

  /// A new container over the same storage behaves like a cold start.
  ProviderContainer newContainer(FakeClock clock) {
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue(''),
        clockProvider.overrideWithValue(clock),
        databaseProvider.overrideWith((ref) => database),
        fastingNotificationServiceProvider.overrideWithValue(
          RecordingFastingNotificationService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Auto-disposed providers stay alive while the Today screen listens.
    container.listen(todaySummaryProvider, (_, _) {});
    return container;
  }

  Future<DaySummary> summaryOf(ProviderContainer container) async {
    await container.read(mealsControllerProvider.future);
    await container.read(fastingControllerProvider.future);
    await container.read(todayCompletedFastsProvider.future);
    await container.read(calorieLimitControllerProvider.future);
    return container.read(todaySummaryProvider).requireValue;
  }

  test('totals match the stored meals and fasts after a restart', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 5));
    final first = newContainer(clock);
    await summaryOf(first);
    final fasting = first.read(fastingControllerProvider.notifier);
    final meals = first.read(mealsControllerProvider.notifier);

    await fasting.start();
    clock.set(DateTime(2026, 9, 10, 12));
    await meals.add(name: 'Rice and beans', calories: 700);
    await meals.add(name: 'Salad', calories: 500);
    clock.set(DateTime(2026, 9, 10, 21, 30));
    await fasting.end();

    final before = await summaryOf(first);
    expect(before.calories, 1200);
    expect(before.fastingTime, const Duration(hours: 16, minutes: 30));
    expect(before.fastingGoalReached, isTrue);
    expect(before.status, DayGoalStatus.within);

    final restarted = await summaryOf(newContainer(clock));
    expect(restarted.calories, 1200);
    expect(restarted.fastingTime, const Duration(hours: 16, minutes: 30));
    expect(restarted.status, DayGoalStatus.within);
  });

  test(
    'a lower calorie limit puts today outside and is kept after a restart',
    () async {
      final clock = FakeClock(DateTime(2026, 9, 10, 12));
      final first = newContainer(clock);
      await summaryOf(first);
      await first
          .read(mealsControllerProvider.notifier)
          .add(name: 'Pasta', calories: 1500);

      expect((await summaryOf(first)).status, DayGoalStatus.inProgress);

      await first.read(calorieLimitControllerProvider.notifier).change(1000);
      final lowered = await summaryOf(first);
      expect(lowered.calorieLimit, 1000);
      expect(lowered.caloriesWithinLimit, isFalse);
      expect(lowered.status, DayGoalStatus.outside);

      final restarted = await summaryOf(newContainer(clock));
      expect(restarted.calorieLimit, 1000);
      expect(restarted.status, DayGoalStatus.outside);
    },
  );

  test('the running fast adds to today as the clock moves', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 6));
    final container = newContainer(clock);
    await summaryOf(container);
    await container.read(fastingControllerProvider.notifier).start();

    clock.advance(const Duration(hours: 2));
    container.read(fastingControllerProvider.notifier).refreshDisplay();

    final summary = await summaryOf(container);
    expect(summary.fastingTime, const Duration(hours: 2));
    expect(summary.status, DayGoalStatus.inProgress);

    await container.read(fastingControllerProvider.notifier).end();
  });
}
