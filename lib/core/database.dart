import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../features/auth/presentation/auth_controller.dart';

/// Opens the app's SQLite database.
///
/// Every table is created here so the schema has one version number. A new
/// table or column bumps [version] and adds a step to `_upgrade`.
abstract final class AppDatabase {
  static const fileName = 'mamba.db';
  static const version = 3;

  /// Rows saved before accounts existed, which have no owner yet.
  static const noUser = '';

  static Future<Database> open(DatabaseFactory factory, String path) {
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
  }

  /// Gives rows saved before accounts existed to [userId].
  static Future<void> claimRowsWithoutUser(Database db, String userId) async {
    if (userId == noUser) return;
    for (final table in ['meals', 'fasting_sessions']) {
      await db.update(
        table,
        {'user_id': userId},
        where: 'user_id = ?',
        whereArgs: [noUser],
      );
    }
  }

  static Future<void> _create(Database db, int version) async {
    await _createMeals(db);
    await _createFastingSessions(db);
  }

  /// Runs every step between the installed version and [version], so an app
  /// updated from any earlier release reaches the current schema.
  static Future<void> _upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) await _createFastingSessions(db);
    if (oldVersion < 3) {
      await _addUserColumn(db, 'meals');
      // A table created by the step above already has the column.
      if (oldVersion >= 2) await _addUserColumn(db, 'fasting_sessions');
      await _createUserIndexes(db);
    }
  }

  static Future<void> _createMeals(Database db) async {
    // eaten_at is UTC epoch milliseconds. Day queries filter on it.
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL DEFAULT '$noUser',
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        eaten_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX meals_user_eaten_at ON meals (user_id, eaten_at)',
    );
  }

  static Future<void> _createFastingSessions(Database db) async {
    // Ended fasts only. The fast that is still running or paused stays in
    // shared_preferences. Timestamps are UTC epoch milliseconds, and a fast
    // counts on the local day of ended_at.
    await db.execute('''
      CREATE TABLE fasting_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT '$noUser',
        protocol_id TEXT NOT NULL,
        target_ms INTEGER NOT NULL,
        started_at INTEGER NOT NULL,
        total_paused_ms INTEGER NOT NULL,
        ended_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX fasting_sessions_user_ended_at '
      'ON fasting_sessions (user_id, ended_at)',
    );
  }

  static Future<void> _addUserColumn(Database db, String table) {
    return db.execute(
      "ALTER TABLE $table ADD COLUMN user_id TEXT NOT NULL DEFAULT '$noUser'",
    );
  }

  static Future<void> _createUserIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS meals_user_eaten_at '
      'ON meals (user_id, eaten_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS fasting_sessions_user_ended_at '
      'ON fasting_sessions (user_id, ended_at)',
    );
  }
}

final databaseProvider = FutureProvider<Database>((ref) async {
  final directory = await getDatabasesPath();
  final database = await AppDatabase.open(
    databaseFactory,
    p.join(directory, AppDatabase.fileName),
  );
  ref.onDispose(database.close);
  return database;
});

/// The database with data from before accounts given to the signed-in user.
final userDatabaseProvider = FutureProvider<Database>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  await AppDatabase.claimRowsWithoutUser(
    database,
    ref.watch(currentUserIdProvider),
  );
  return database;
});
