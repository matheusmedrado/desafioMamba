import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/domain/auth_failure.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository accounts;

  setUp(() => accounts = FakeAuthRepository());

  // A new container with the same accounts behaves like a restarted app.
  ProviderContainer newContainer() {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(accounts)],
    );
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, _) {});
    return container;
  }

  test('starts signed out', () async {
    final container = newContainer();

    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('sign up signs in with the normalized email', () async {
    final container = newContainer();
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .signUp(email: '  User@Example.com ', password: 'password1');
    await pumpEventQueue();

    expect(
      container.read(authControllerProvider).value?.email,
      'user@example.com',
    );
  });

  test('a wrong password is rejected and stays signed out', () async {
    accounts.addAccount('user@example.com', 'password1');
    final container = newContainer();
    await container.read(authControllerProvider.future);

    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .signIn(email: 'user@example.com', password: 'password2'),
      throwsA(AuthFailure.invalidCredentials),
    );
    await pumpEventQueue();

    expect(container.read(authControllerProvider).value, isNull);
  });

  test('the session is restored by a fresh container', () async {
    accounts.addAccount('user@example.com', 'password1');
    final first = newContainer();
    await first.read(authControllerProvider.future);
    await first
        .read(authControllerProvider.notifier)
        .signIn(email: 'user@example.com', password: 'password1');

    final second = newContainer();

    final restored = await second.read(authControllerProvider.future);
    expect(restored?.email, 'user@example.com');
  });

  test('sign out ends the session, also after a restart', () async {
    accounts.addAccount('user@example.com', 'password1');
    final first = newContainer();
    await first.read(authControllerProvider.future);
    final auth = first.read(authControllerProvider.notifier);
    await auth.signIn(email: 'user@example.com', password: 'password1');

    await auth.signOut();
    await pumpEventQueue();
    expect(first.read(authControllerProvider).value, isNull);

    final second = newContainer();
    expect(await second.read(authControllerProvider.future), isNull);
  });

  test('a password reset goes to the normalized email', () async {
    final container = newContainer();

    await container
        .read(authControllerProvider.notifier)
        .sendPasswordReset(' User@Example.com');

    expect(accounts.resetRequests, ['user@example.com']);
  });
}
