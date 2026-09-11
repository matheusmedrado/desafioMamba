import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<List<Object?>> tableNames(Database database) async {
    final rows = await database.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table'",
    );
    return rows.map((row) => row['name']).toList();
  }

  Future<List<Object?>> columnNames(Database database, String table) async {
    final rows = await database.rawQuery('PRAGMA table_info($table)');
    return rows.map((row) => row['name']).toList();
  }

  Future<String> newDatabasePath(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    addTearDown(() => directory.delete(recursive: true));
    return p.join(directory.path, AppDatabase.fileName);
  }

  test('a new database has the meals and fasting sessions tables', () async {
    final database = await AppDatabase.open(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    expect(await database.getVersion(), AppDatabase.version);
    expect(
      await tableNames(database),
      containsAll(['meals', 'fasting_sessions']),
    );
    expect(await columnNames(database, 'meals'), contains('user_id'));
    expect(
      await columnNames(database, 'fasting_sessions'),
      contains('user_id'),
    );
  });

  test(
    'upgrading a version 1 database adds fasting sessions and keeps meals',
    () async {
      final path = await newDatabasePath('mamba_db');

      // The schema shipped with meal tracking, before completed fasts existed.
      final version1 = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => db.execute('''
          CREATE TABLE meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            calories INTEGER NOT NULL,
            eaten_at INTEGER NOT NULL
          )
        '''),
        ),
      );
      await version1.insert('meals', {
        'name': 'Toast',
        'calories': 180,
        'eaten_at': DateTime.utc(2026, 9, 10, 8).millisecondsSinceEpoch,
      });
      await version1.close();

      final upgraded = await AppDatabase.open(databaseFactoryFfi, path);
      addTearDown(upgraded.close);

      expect(await upgraded.getVersion(), AppDatabase.version);
      expect(await tableNames(upgraded), contains('fasting_sessions'));
      final [meal] = await upgraded.query('meals');
      expect(meal['name'], 'Toast');
      expect(meal['calories'], 180);
      expect(meal['user_id'], AppDatabase.noUser);
    },
  );

  test(
    'rows saved before accounts go to the first account that signs in',
    () async {
      final path = await newDatabasePath('mamba_db_v2');

      // The schema shipped before accounts, without a user column.
      final version2 = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE meals (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                calories INTEGER NOT NULL,
                eaten_at INTEGER NOT NULL
              )
            ''');
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
          },
        ),
      );
      await version2.insert('meals', {
        'name': 'Toast',
        'calories': 180,
        'eaten_at': DateTime.utc(2026, 9, 10, 8).millisecondsSinceEpoch,
      });
      await version2.insert('fasting_sessions', {
        'id': 'fast-1',
        'protocol_id': '16:8',
        'target_ms': const Duration(hours: 16).inMilliseconds,
        'started_at': DateTime.utc(2026, 9, 9, 20).millisecondsSinceEpoch,
        'total_paused_ms': 0,
        'ended_at': DateTime.utc(2026, 9, 10, 12).millisecondsSinceEpoch,
      });
      await version2.close();

      final upgraded = await AppDatabase.open(databaseFactoryFfi, path);
      addTearDown(upgraded.close);
      await AppDatabase.claimRowsWithoutUser(upgraded, 'user-1');
      // A second account finds nothing left to take over.
      await AppDatabase.claimRowsWithoutUser(upgraded, 'user-2');

      final [meal] = await upgraded.query('meals');
      final [fast] = await upgraded.query('fasting_sessions');
      expect(meal['user_id'], 'user-1');
      expect(fast['user_id'], 'user-1');
    },
  );

  test('claiming rows without a signed-in user changes nothing', () async {
    final database = await AppDatabase.open(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.insert('meals', {
      'name': 'Toast',
      'calories': 180,
      'eaten_at': DateTime.utc(2026, 9, 10, 8).millisecondsSinceEpoch,
    });

    await AppDatabase.claimRowsWithoutUser(database, AppDatabase.noUser);

    final [meal] = await database.query('meals');
    expect(meal['user_id'], AppDatabase.noUser);
  });
}
