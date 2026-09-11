import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/meals_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;

  setUp(() async {
    database = await AppDatabase.open(databaseFactoryFfi, inMemoryDatabasePath);
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
    // The provider is auto-disposed. Keep it alive like the Meals screen does.
    container.listen(mealsControllerProvider, (_, _) {});
    return container;
  }

  test('adds a meal with a trimmed name and the current time', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 12, 30));
    final container = newContainer(clock);

    expect(await container.read(mealsControllerProvider.future), isEmpty);
    await container
        .read(mealsControllerProvider.notifier)
        .add(name: '  Oat bowl  ', calories: 420);

    final [meal] = container.read(mealsControllerProvider).value!;
    expect(meal.name, 'Oat bowl');
    expect(meal.calories, 420);
    expect(meal.eatenAt, clock.now().toUtc());
  });

  test('edit keeps the original time and delete removes the meal', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 8));
    final container = newContainer(clock);
    final controller = container.read(mealsControllerProvider.notifier);
    await container.read(mealsControllerProvider.future);

    await controller.add(name: 'Toast', calories: 180);
    final [added] = container.read(mealsControllerProvider).value!;

    clock.advance(const Duration(hours: 3));
    await controller.edit(added, name: 'Toast with jam', calories: 240);
    final [edited] = container.read(mealsControllerProvider).value!;
    expect(edited.name, 'Toast with jam');
    expect(edited.calories, 240);
    expect(edited.eatenAt, added.eatenAt);

    await controller.delete(edited);
    expect(container.read(mealsControllerProvider).value, isEmpty);
  });

  test('rejects invalid meals without saving them', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 12));
    final container = newContainer(clock);
    final controller = container.read(mealsControllerProvider.notifier);
    await container.read(mealsControllerProvider.future);

    expect(() => controller.add(name: ' ', calories: 300), throwsArgumentError);
    expect(
      () => controller.add(name: 'Soup', calories: 0),
      throwsArgumentError,
    );
    expect(
      () => controller.add(name: 'Feast', calories: 5001),
      throwsArgumentError,
    );

    await controller.refresh();
    expect(container.read(mealsControllerProvider).value, isEmpty);
  });

  test(
    'meals are restored by a new container reading the same storage',
    () async {
      final clock = FakeClock(DateTime(2026, 9, 10, 12));
      final first = newContainer(clock);
      await first.read(mealsControllerProvider.future);
      await first
          .read(mealsControllerProvider.notifier)
          .add(name: 'Rice and beans', calories: 650);

      final second = newContainer(clock);
      final restored = await second.read(mealsControllerProvider.future);

      expect(restored.map((meal) => meal.name), ['Rice and beans']);
    },
  );

  test('refresh after midnight shows the new day', () async {
    final clock = FakeClock(DateTime(2026, 9, 10, 22));
    final container = newContainer(clock);
    final controller = container.read(mealsControllerProvider.notifier);
    await container.read(mealsControllerProvider.future);
    await controller.add(name: 'Late snack', calories: 150);

    clock.set(DateTime(2026, 9, 11, 7));
    await controller.refresh();

    expect(container.read(mealsControllerProvider).value, isEmpty);
  });
}
