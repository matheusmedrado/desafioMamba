import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/fasting/data/completed_fast_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fake_fasting_notification_service.dart';

/// Simulates a device where the database cannot be written.
class FailingCompletedFastRepository implements CompletedFastRepository {
  @override
  Future<void> save(FastingSession fast) async {
    throw StateError('Database unavailable.');
  }

  @override
  Future<List<FastingSession>> endedOn(DateTime day) async {
    throw StateError('Database unavailable.');
  }
}

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    database = await AppDatabase.open(databaseFactoryFfi, inMemoryDatabasePath);
  });

  tearDown(() => database.close());

  ProviderContainer newContainer(
    FakeClock clock, {
    FastingNotificationService? notifications,
    CompletedFastRepository? completedFasts,
  }) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        databaseProvider.overrideWith((ref) => database),
        fastingNotificationServiceProvider.overrideWithValue(
          notifications ?? RecordingFastingNotificationService(),
        ),
        if (completedFasts != null)
          completedFastRepositoryProvider.overrideWith((ref) => completedFasts),
      ],
    );
    addTearDown(container.dispose);
    // The provider is auto-disposed. Keep it alive like the timer screen does.
    container.listen(fastingControllerProvider, (_, _) {});
    return container;
  }

  Future<List<FastingSession>> completedOn(
    ProviderContainer container,
    DateTime day,
  ) async {
    final completed = await container.read(
      completedFastRepositoryProvider.future,
    );
    return completed.endedOn(day);
  }

  test(
    'start persists the selected protocol and restores after a restart',
    () async {
      final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
      final notifications = RecordingFastingNotificationService();
      final first = newContainer(clock, notifications: notifications);

      await first.read(fastingControllerProvider.future);
      await first.read(fastingControllerProvider.notifier).start();
      clock.advance(const Duration(hours: 3));

      final second = newContainer(clock, notifications: notifications);
      final restored = await second.read(fastingControllerProvider.future);

      expect(restored, isNotNull);
      expect(restored!.protocolId, '16:8');
      expect(restored.status, FastingStatus.running);
      expect(restored.elapsedAt(clock.now()), const Duration(hours: 3));
      expect(notifications.startedCount, 1);
      expect(notifications.syncCalls, hasLength(3));
      expect(notifications.syncCalls.first.session, isNull);
      expect(notifications.syncCalls.last.session, restored);
    },
  );

  test(
    'pause and resume persist active elapsed time without counting the pause',
    () async {
      final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
      final container = newContainer(clock);
      final controller = container.read(fastingControllerProvider.notifier);

      await container.read(fastingControllerProvider.future);
      await controller.start();
      clock.advance(const Duration(hours: 2));
      await controller.pause();
      clock.advance(const Duration(hours: 5));

      final paused = container.read(fastingControllerProvider).value!;
      expect(paused.status, FastingStatus.paused);
      expect(paused.elapsedAt(clock.now()), const Duration(hours: 2));

      await controller.resume();
      clock.advance(const Duration(hours: 1));
      final resumed = container.read(fastingControllerProvider).value!;

      expect(resumed.status, FastingStatus.running);
      expect(resumed.totalPaused, const Duration(hours: 5));
      expect(resumed.elapsedAt(clock.now()), const Duration(hours: 3));
    },
  );

  test(
    'restoring after the target keeps a running session marked as reached',
    () async {
      final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
      final notifications = RecordingFastingNotificationService();
      final first = newContainer(clock, notifications: notifications);
      await first.read(fastingControllerProvider.future);
      await first.read(fastingControllerProvider.notifier).start();
      clock.advance(const Duration(hours: 17));

      final second = newContainer(clock, notifications: notifications);
      final restored = await second.read(fastingControllerProvider.future);

      expect(restored!.status, FastingStatus.running);
      expect(restored.goalReachedAt(clock.now()), isTrue);
      expect(restored.endedAt, isNull);
      expect(notifications.syncCalls, hasLength(3));
    },
  );

  test('ending persists the ended state', () async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final first = newContainer(clock);
    await first.read(fastingControllerProvider.future);
    await first.read(fastingControllerProvider.notifier).start();
    clock.advance(const Duration(hours: 4));
    await first.read(fastingControllerProvider.notifier).end();

    final second = newContainer(clock);
    final restored = await second.read(fastingControllerProvider.future);

    expect(restored!.status, FastingStatus.ended);
    expect(restored.endedAt, clock.now());
    expect(restored.elapsedAt(clock.now()), const Duration(hours: 4));
  });

  test('ending a fast copies it to completed fasts', () async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final container = newContainer(clock);
    final controller = container.read(fastingControllerProvider.notifier);
    await container.read(fastingControllerProvider.future);

    await controller.start();
    clock.advance(const Duration(hours: 3));
    expect(await completedOn(container, clock.now()), isEmpty);

    await controller.end();
    final ended = container.read(fastingControllerProvider).value!;

    expect(await completedOn(container, clock.now()), [ended]);
  });

  test(
    'an ended fast that was not copied is copied once when it loads',
    () async {
      final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
      // The app closed after saving the end but before copying the fast.
      final ended = FastingSession.start(
        id: 'fast-1',
        protocolId: '16:8',
        target: const Duration(hours: 16),
        startedAt: DateTime.utc(2026, 9, 9, 20),
      ).endAt(DateTime.utc(2026, 9, 10, 7));
      await FastingRepository(SharedPreferencesAsync()).save(ended);

      final container = newContainer(clock);
      expect(await container.read(fastingControllerProvider.future), ended);
      await container.read(fastingControllerProvider.notifier).restore();

      expect(await completedOn(container, clock.now()), [ended]);
    },
  );

  test('a failed copy to completed fasts does not block ending', () async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final container = newContainer(
      clock,
      completedFasts: FailingCompletedFastRepository(),
    );
    final controller = container.read(fastingControllerProvider.notifier);
    await container.read(fastingControllerProvider.future);

    await controller.start();
    clock.advance(const Duration(hours: 2));
    await controller.end();

    final ended = container.read(fastingControllerProvider).value!;
    expect(ended.status, FastingStatus.ended);
    expect(await FastingRepository(SharedPreferencesAsync()).load(), ended);
  });

  test('syncs notifications after each session transition', () async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final notifications = RecordingFastingNotificationService();
    final container = newContainer(clock, notifications: notifications);
    final controller = container.read(fastingControllerProvider.notifier);

    await container.read(fastingControllerProvider.future);
    await controller.start();
    await controller.pause();
    await controller.resume();
    await controller.end();

    expect(notifications.startedCount, 1);
    expect(notifications.syncCalls.map((call) => call.session?.status), [
      null,
      FastingStatus.running,
      FastingStatus.paused,
      FastingStatus.running,
      FastingStatus.ended,
    ]);
  });

  test('restoring with no session still synchronizes cancellation', () async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final notifications = RecordingFastingNotificationService();
    final container = newContainer(clock, notifications: notifications);
    final controller = container.read(fastingControllerProvider.notifier);

    await container.read(fastingControllerProvider.future);
    await controller.start();
    await container.read(fastingRepositoryProvider).clear();
    await controller.restore();

    expect(notifications.syncCalls.last.session, isNull);
    expect(container.read(fastingControllerProvider).value, isNull);
  });

  test('notification failures do not block the fasting timer', () async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final container = newContainer(
      clock,
      notifications: FailingFastingNotificationService(),
    );
    final controller = container.read(fastingControllerProvider.notifier);

    expect(await container.read(fastingControllerProvider.future), isNull);
    await controller.start();
    expect(
      container.read(fastingControllerProvider).value?.status,
      FastingStatus.running,
    );

    clock.advance(const Duration(hours: 1));
    await controller.pause();
    final paused = container.read(fastingControllerProvider).value!;
    expect(paused.status, FastingStatus.paused);
    expect(paused.elapsedAt(clock.now()), const Duration(hours: 1));

    await controller.restore();
    expect(container.read(fastingControllerProvider).value, paused);
  });
}
