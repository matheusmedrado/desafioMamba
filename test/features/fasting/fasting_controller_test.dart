import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  ProviderContainer newContainer(FakeClock clock) {
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(clock)],
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
      final first = newContainer(clock);

      await first.read(fastingControllerProvider.future);
      await first.read(fastingControllerProvider.notifier).start();
      clock.advance(const Duration(hours: 3));

      final second = newContainer(clock);
      final restored = await second.read(fastingControllerProvider.future);

      expect(restored, isNotNull);
      expect(restored!.protocolId, '16:8');
      expect(restored.status, FastingStatus.running);
      expect(restored.elapsedAt(clock.now()), const Duration(hours: 3));
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
      final first = newContainer(clock);
      await first.read(fastingControllerProvider.future);
      await first.read(fastingControllerProvider.notifier).start();
      clock.advance(const Duration(hours: 17));

      final second = newContainer(clock);
      final restored = await second.read(fastingControllerProvider.future);

      expect(restored!.status, FastingStatus.running);
      expect(restored.goalReachedAt(clock.now()), isTrue);
      expect(restored.endedAt, isNull);
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
}
