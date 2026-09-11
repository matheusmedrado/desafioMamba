import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database.dart';
import '../domain/meal.dart';

/// Owns persisted meals.
class MealRepository {
  MealRepository(this._database);

  static const _table = 'meals';

  final Database _database;

  /// Meals eaten during the local calendar day that contains [day], oldest
  /// first.
  Future<List<Meal>> mealsOn(DateTime day) async {
    final local = day.toLocal();
    // Built from calendar fields so a day with a DST change still ends at the
    // next local midnight.
    final start = DateTime(local.year, local.month, local.day);
    final end = DateTime(local.year, local.month, local.day + 1);
    final rows = await _database.query(
      _table,
      where: 'eaten_at >= ? AND eaten_at < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'eaten_at, id',
    );
    return rows.map(_fromRow).toList();
  }

  Future<Meal> add({
    required String name,
    required int calories,
    required DateTime eatenAt,
  }) async {
    final id = await _database.insert(_table, {
      'name': name,
      'calories': calories,
      'eaten_at': eatenAt.millisecondsSinceEpoch,
    });
    return Meal(id: id, name: name, calories: calories, eatenAt: eatenAt);
  }

  /// Saves a new name and calories. The meal time is never rewritten.
  Future<void> update(Meal meal) async {
    final count = await _database.update(
      _table,
      {'name': meal.name, 'calories': meal.calories},
      where: 'id = ?',
      whereArgs: [meal.id],
    );
    if (count == 0) {
      throw StateError('Meal ${meal.id} no longer exists.');
    }
  }

  Future<void> delete(int id) async {
    await _database.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  static Meal _fromRow(Map<String, Object?> row) {
    return Meal(
      id: row['id']! as int,
      name: row['name']! as String,
      calories: row['calories']! as int,
      eatenAt: DateTime.fromMillisecondsSinceEpoch(
        row['eaten_at']! as int,
        isUtc: true,
      ),
    );
  }
}

final mealRepositoryProvider = FutureProvider<MealRepository>((ref) async {
  return MealRepository(await ref.watch(databaseProvider.future));
});
