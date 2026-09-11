import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/meals/data/meal_repository.dart';
import 'package:mamba_fast_tracker/features/meals/domain/meal.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  const user = 'user-1';

  Future<Database> openInMemory() async {
    final database = await AppDatabase.open(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return database;
  }

  Future<MealRepository> newRepository() async {
    return MealRepository(await openInMemory(), user);
  }

  test('adds a meal and reads it back on the same day', () async {
    final repository = await newRepository();
    final eatenAt = DateTime(2026, 9, 10, 12, 30);

    final meal = await repository.add(
      name: 'Oat bowl',
      calories: 420,
      eatenAt: eatenAt,
    );

    expect(meal.eatenAt, eatenAt.toUtc());
    expect(await repository.mealsOn(DateTime(2026, 9, 10)), [meal]);
  });

  test(
    'lists only meals inside the local calendar day, oldest first',
    () async {
      final repository = await newRepository();
      Future<Meal> addAt(DateTime time) =>
          repository.add(name: 'Meal', calories: 100, eatenAt: time);

      await addAt(DateTime(2026, 9, 9, 23, 59, 59));
      final lastOfDay = await addAt(DateTime(2026, 9, 10, 23, 59, 59));
      final firstOfDay = await addAt(DateTime(2026, 9, 10));
      await addAt(DateTime(2026, 9, 11));

      expect(await repository.mealsOn(DateTime(2026, 9, 10, 15)), [
        firstOfDay,
        lastOfDay,
      ]);
    },
  );

  test('update changes name and calories but keeps the meal time', () async {
    final repository = await newRepository();
    final meal = await repository.add(
      name: 'Salad',
      calories: 300,
      eatenAt: DateTime(2026, 9, 10, 13),
    );

    await repository.update(
      meal.copyWith(name: 'Chicken salad', calories: 520),
    );

    final [saved] = await repository.mealsOn(DateTime(2026, 9, 10));
    expect(saved.name, 'Chicken salad');
    expect(saved.calories, 520);
    expect(saved.eatenAt, meal.eatenAt);
  });

  test(
    'updating a deleted meal fails instead of silently doing nothing',
    () async {
      final repository = await newRepository();
      final meal = await repository.add(
        name: 'Toast',
        calories: 180,
        eatenAt: DateTime(2026, 9, 10, 8),
      );
      await repository.delete(meal.id);

      expect(repository.mealsOn(DateTime(2026, 9, 10)), completion(isEmpty));
      expect(
        () => repository.update(meal.copyWith(calories: 200)),
        throwsStateError,
      );
    },
  );

  test('saved changes remain after the database is reopened', () async {
    final directory = await Directory.systemTemp.createTemp('mamba_meals');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, AppDatabase.fileName);
    final day = DateTime(2026, 9, 10);

    final first = await AppDatabase.open(databaseFactoryFfi, path);
    final repository = MealRepository(first, user);
    final kept = await repository.add(
      name: 'Eggs',
      calories: 210,
      eatenAt: DateTime(2026, 9, 10, 9),
    );
    final removed = await repository.add(
      name: 'Juice',
      calories: 120,
      eatenAt: DateTime(2026, 9, 10, 9, 5),
    );
    await repository.update(kept.copyWith(name: 'Scrambled eggs'));
    await repository.delete(removed.id);
    await first.close();

    final second = await AppDatabase.open(databaseFactoryFfi, path);
    addTearDown(second.close);

    expect(await MealRepository(second, user).mealsOn(day), [
      kept.copyWith(name: 'Scrambled eggs'),
    ]);
  });

  test(
    'mealsBefore lists meals from earlier local days, oldest first',
    () async {
      final repository = await newRepository();
      Future<Meal> addAt(DateTime time) =>
          repository.add(name: 'Meal', calories: 100, eatenAt: time);

      final lastOfYesterday = await addAt(DateTime(2026, 9, 9, 23, 59, 59));
      final older = await addAt(DateTime(2026, 9, 1, 12));
      await addAt(DateTime(2026, 9, 10));

      expect(await repository.mealsBefore(DateTime(2026, 9, 10, 15)), [
        older,
        lastOfYesterday,
      ]);
    },
  );

  test('a meal belongs to the account that added it', () async {
    final database = await openInMemory();
    final mine = MealRepository(database, user);
    final other = MealRepository(database, 'user-2');
    final day = DateTime(2026, 9, 10);

    final meal = await mine.add(
      name: 'Oat bowl',
      calories: 420,
      eatenAt: DateTime(2026, 9, 10, 12),
    );
    await other.add(
      name: 'Pasta',
      calories: 800,
      eatenAt: DateTime(2026, 9, 10, 20),
    );

    expect(await mine.mealsOn(day), [meal]);
    expect(await mine.mealsBefore(DateTime(2026, 9, 11)), [meal]);
    expect((await other.mealsOn(day)).single.name, 'Pasta');
  });

  test('another account cannot change or delete a meal', () async {
    final database = await openInMemory();
    final mine = MealRepository(database, user);
    final other = MealRepository(database, 'user-2');
    final meal = await mine.add(
      name: 'Oat bowl',
      calories: 420,
      eatenAt: DateTime(2026, 9, 10, 12),
    );

    expect(() => other.update(meal.copyWith(calories: 10)), throwsStateError);
    await other.delete(meal.id);

    expect(await mine.mealsOn(DateTime(2026, 9, 10)), [meal]);
  });

  test('totalCalories sums the meals', () {
    final eatenAt = DateTime.utc(2026, 9, 10, 12);
    expect(totalCalories([]), 0);
    expect(
      totalCalories([
        Meal(id: 1, name: 'A', calories: 420, eatenAt: eatenAt),
        Meal(id: 2, name: 'B', calories: 820, eatenAt: eatenAt),
      ]),
      1240,
    );
  });
}
