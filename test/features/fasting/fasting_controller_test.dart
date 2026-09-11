import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_fasting_notification_service.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  ProviderContainer newContainer(
    FakeClock clock, {
    RecordingFastingNotificationService? notifications,
  }) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        fastingNotificationServiceProvider.overrideWithValue(
          notifications ?? RecordingFastingNotificationService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    // The provider is auto-disposed. Keep it alive like the timer screen does.
    container.listen(fastingControllerProvider, (_, _) {});
    return container;
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
}
