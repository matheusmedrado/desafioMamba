import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the app's SQLite database.
///
/// Every table is created here so the schema has one version number. A later
/// table is added with a version bump and an `onUpgrade` step.
abstract final class AppDatabase {
  static const fileName = 'mamba.db';
  static const version = 1;

  static Future<Database> open(DatabaseFactory factory, String path) {
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: version, onCreate: _create),
    );
  }

  static Future<void> _create(Database db, int version) async {
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
