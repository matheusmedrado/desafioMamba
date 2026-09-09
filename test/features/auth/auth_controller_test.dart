import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  final clock = FakeClock(DateTime.utc(2026, 9, 9, 8));

  ProviderContainer newContainer() {
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(clock)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    // Storage survives across containers within a test, which simulates
    // the app process being restarted.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('starts signed out', () async {
    final container = newContainer();

    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('login normalizes the email and stamps the clock time', () async {
    final container = newContainer();
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .login(email: '  User@Example.com ', password: 'password1');

    final session = container.read(authControllerProvider).value;
    expect(session?.email, 'user@example.com');
    expect(session?.signedInAt, DateTime.utc(2026, 9, 9, 8));
  });

  test('session is restored by a fresh container', () async {
    final first = newContainer();
    await first.read(authControllerProvider.future);
    await first
        .read(authControllerProvider.notifier)
        .login(email: 'user@example.com', password: 'password1');

    final second = newContainer();

    final restored = await second.read(authControllerProvider.future);
    expect(restored?.email, 'user@example.com');
  });

  test('logout clears storage so a restart stays signed out', () async {
    final first = newContainer();
    await first.read(authControllerProvider.future);
    await first
        .read(authControllerProvider.notifier)
        .login(email: 'user@example.com', password: 'password1');

    await first.read(authControllerProvider.notifier).logout();
    expect(first.read(authControllerProvider).value, isNull);

    final second = newContainer();
    expect(await second.read(authControllerProvider.future), isNull);
  });
}
