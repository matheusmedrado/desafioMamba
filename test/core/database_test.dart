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
  });

  test(
    'upgrading a version 1 database adds fasting sessions and keeps meals',
    () async {
      final directory = await Directory.systemTemp.createTemp('mamba_db');
      addTearDown(() => directory.delete(recursive: true));
      final path = p.join(directory.path, AppDatabase.fileName);

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
    },
  );
}
