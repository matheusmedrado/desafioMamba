import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the app's SQLite database.
///
/// Every table is created here so the schema has one version number. A new
/// table or column bumps [version] and adds a step to `_upgrade`.
abstract final class AppDatabase {
  static const fileName = 'mamba.db';
  static const version = 2;

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
  }

  static Future<void> _createMeals(Database db) async {
    // eaten_at is UTC epoch milliseconds. Day queries filter on it.
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        eaten_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX meals_eaten_at ON meals (eaten_at)');
  }

  static Future<void> _createFastingSessions(Database db) async {
    // Ended fasts only. The fast that is still running or paused stays in
    // shared_preferences. Timestamps are UTC epoch milliseconds, and a fast
    // counts on the local day of ended_at.
    await db.execute('''
      CREATE TABLE fasting_sessions (
        id TEXT PRIMARY KEY,
        protocol_id TEXT NOT NULL,
        target_ms INTEGER NOT NULL,
        started_at INTEGER NOT NULL,
        total_paused_ms INTEGER NOT NULL,
        ended_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX fasting_sessions_ended_at ON fasting_sessions (ended_at)',
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
