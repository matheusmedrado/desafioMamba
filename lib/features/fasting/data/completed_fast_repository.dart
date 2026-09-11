import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database.dart';
import '../../../core/local_day.dart';
import '../domain/fasting_session.dart';

/// Owns fasts that have ended.
///
/// The fast that is still running or paused is owned by `FastingRepository`.
/// A fast is copied here when it ends.
class CompletedFastRepository {
  CompletedFastRepository(this._database);

  static const _table = 'fasting_sessions';

  final Database _database;

  /// Saves an ended fast. Saving the same fast again replaces its record, so
  /// repeating the copy after an interrupted end does not duplicate it.
  Future<void> save(FastingSession fast) async {
    final endedAt = fast.endedAt;
    if (fast.status != FastingStatus.ended || endedAt == null) {
      throw ArgumentError.value(fast.status, 'fast', 'must be ended');
    }
    await _database.insert(_table, {
      'id': fast.id,
      'protocol_id': fast.protocolId,
      'target_ms': fast.target.inMilliseconds,
      'started_at': fast.startedAt.millisecondsSinceEpoch,
      'total_paused_ms': fast.totalPaused.inMilliseconds,
      'ended_at': endedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fasts that ended during the local calendar day that contains [day],
  /// oldest first.
  Future<List<FastingSession>> endedOn(DateTime day) async {
    final bounds = localDayBounds(day);
    final rows = await _database.query(
      _table,
      where: 'ended_at >= ? AND ended_at < ?',
      whereArgs: [
        bounds.start.millisecondsSinceEpoch,
        bounds.end.millisecondsSinceEpoch,
      ],
      orderBy: 'ended_at, id',
    );
    return rows.map(_fromRow).toList();
  }

  static FastingSession _fromRow(Map<String, Object?> row) {
    DateTime timestamp(String column) =>
        DateTime.fromMillisecondsSinceEpoch(row[column]! as int, isUtc: true);

    return FastingSession(
      id: row['id']! as String,
      protocolId: row['protocol_id']! as String,
      target: Duration(milliseconds: row['target_ms']! as int),
      startedAt: timestamp('started_at'),
      totalPaused: Duration(milliseconds: row['total_paused_ms']! as int),
      endedAt: timestamp('ended_at'),
      status: FastingStatus.ended,
    );
  }
}

final completedFastRepositoryProvider = FutureProvider<CompletedFastRepository>(
  (ref) async {
    return CompletedFastRepository(await ref.watch(databaseProvider.future));
  },
);
