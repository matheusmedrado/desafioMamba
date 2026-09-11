import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/fasting/data/completed_fast_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<CompletedFastRepository> newRepository() async {
    final database = await AppDatabase.open(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    return CompletedFastRepository(database);
  }

  FastingSession endedFast(
    String id,
    DateTime start,
    DateTime end, {
    Duration paused = Duration.zero,
  }) {
    return FastingSession(
      id: id,
      protocolId: '16:8',
      target: const Duration(hours: 16),
      startedAt: start,
      totalPaused: paused,
      endedAt: end,
      status: FastingStatus.ended,
    );
  }

  test(
    'a fast is listed on the day it ended, not the day it started',
    () async {
      final repository = await newRepository();
      final fast = endedFast(
        'fast-1',
        DateTime(2026, 9, 9, 20),
        DateTime(2026, 9, 10, 12, 30),
        paused: const Duration(minutes: 25),
      );

      await repository.save(fast);

      expect(await repository.endedOn(DateTime(2026, 9, 9)), isEmpty);
      expect(await repository.endedOn(DateTime(2026, 9, 10, 18)), [fast]);
    },
  );

  test('lists fasts that ended inside the local day, oldest first', () async {
    final repository = await newRepository();
    FastingSession endingAt(String id, DateTime end) =>
        endedFast(id, end.subtract(const Duration(hours: 8)), end);

    final lastOfDay = endingAt('last', DateTime(2026, 9, 10, 23, 59, 59));
    final before = endingAt('before', DateTime(2026, 9, 9, 23, 59, 59));
    final firstOfDay = endingAt('first', DateTime(2026, 9, 10));
    final after = endingAt('after', DateTime(2026, 9, 11));
    for (final fast in [lastOfDay, before, firstOfDay, after]) {
      await repository.save(fast);
    }

    expect(await repository.endedOn(DateTime(2026, 9, 10)), [
      firstOfDay,
      lastOfDay,
    ]);
  });

  test('endedBefore lists fasts that ended on earlier local days', () async {
    final repository = await newRepository();
    final crossedMidnight = endedFast(
      'crossed',
      DateTime(2026, 9, 9, 20),
      DateTime(2026, 9, 10, 12),
    );
    final yesterday = endedFast(
      'yesterday',
      DateTime(2026, 9, 9, 1),
      DateTime(2026, 9, 9, 17),
    );
    final older = endedFast(
      'older',
      DateTime(2026, 9, 2, 1),
      DateTime(2026, 9, 2, 17),
    );
    for (final fast in [crossedMidnight, yesterday, older]) {
      await repository.save(fast);
    }

    expect(await repository.endedBefore(DateTime(2026, 9, 10, 18)), [
      older,
      yesterday,
    ]);
  });

  test('saving the same fast again keeps one record', () async {
    final repository = await newRepository();
    final fast = endedFast(
      'fast-1',
      DateTime(2026, 9, 10, 1),
      DateTime(2026, 9, 10, 17),
    );

    await repository.save(fast);
    await repository.save(fast);

    expect(await repository.endedOn(DateTime(2026, 9, 10)), [fast]);
  });

  test('rejects a fast that has not ended', () async {
    final repository = await newRepository();
    final running = FastingSession.start(
      id: 'fast-1',
      protocolId: '16:8',
      target: const Duration(hours: 16),
      startedAt: DateTime(2026, 9, 10, 1),
    );

    expect(() => repository.save(running), throwsArgumentError);
  });
}
