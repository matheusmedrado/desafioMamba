import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database.dart';
import '../../../core/local_day.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/meal.dart';

/// Owns the persisted meals of one user.
class MealRepository {
  MealRepository(this._database, this._userId);

  static const _table = 'meals';

  final Database _database;
  final String _userId;

  /// Meals eaten during the local calendar day that contains [day], oldest
  /// first.
  Future<List<Meal>> mealsOn(DateTime day) async {
    final bounds = localDayBounds(day);
    final rows = await _database.query(
      _table,
      where: 'user_id = ? AND eaten_at >= ? AND eaten_at < ?',
      whereArgs: [
        _userId,
        bounds.start.millisecondsSinceEpoch,
        bounds.end.millisecondsSinceEpoch,
      ],
      orderBy: 'eaten_at, id',
    );
    return rows.map(_fromRow).toList();
  }

  /// Meals eaten before the local day that contains [day], oldest first.
  Future<List<Meal>> mealsBefore(DateTime day) async {
    final rows = await _database.query(
      _table,
      where: 'user_id = ? AND eaten_at < ?',
      whereArgs: [_userId, localDayBounds(day).start.millisecondsSinceEpoch],
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
      'user_id': _userId,
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
      where: 'id = ? AND user_id = ?',
      whereArgs: [meal.id, _userId],
    );
    if (count == 0) {
      throw StateError('Meal ${meal.id} no longer exists.');
    }
  }

  Future<void> delete(int id) async {
    await _database.delete(
      _table,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );
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
  return MealRepository(
    await ref.watch(userDatabaseProvider.future),
    ref.watch(currentUserIdProvider),
  );
});
