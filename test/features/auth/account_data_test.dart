import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:mamba_fast_tracker/features/dashboard/data/calorie_limit_repository.dart';
import 'package:mamba_fast_tracker/features/dashboard/domain/calorie_limit.dart';
import 'package:mamba_fast_tracker/features/meals/data/meal_repository.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fake_auth_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  final day = DateTime(2026, 9, 10);

  late Database database;
  late FakeAuthRepository accounts;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    accounts = FakeAuthRepository()
      ..addAccount('a@example.com', 'password1')
      ..addAccount('b@example.com', 'password1');
    database = await AppDatabase.open(databaseFactoryFfi, inMemoryDatabasePath);
  });

  tearDown(() => database.close());

  Future<ProviderContainer> newContainer() async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(accounts),
        databaseProvider.overrideWith((ref) => database),
      ],
    );
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, _) {});
    await container.read(authControllerProvider.future);
    return container;
  }

  Future<void> signIn(ProviderContainer container, String email) async {
    await container
        .read(authControllerProvider.notifier)
        .signIn(email: email, password: 'password1');
    await pumpEventQueue();
  }

  Future<void> signOut(ProviderContainer container) async {
    await container.read(authControllerProvider.notifier).signOut();
    await pumpEventQueue();
  }

  test('each account sees only its own meals and calorie limit', () async {
    final container = await newContainer();

    await signIn(container, 'a@example.com');
    final mealsOfA = await container.read(mealRepositoryProvider.future);
    await mealsOfA.add(
      name: 'Oat bowl',
      calories: 420,
      eatenAt: DateTime(2026, 9, 10, 12),
    );
    await container.read(calorieLimitRepositoryProvider).save(1800);

    await signOut(container);
    await signIn(container, 'b@example.com');

    final mealsOfB = await container.read(mealRepositoryProvider.future);
    expect(await mealsOfB.mealsOn(day), isEmpty);
    expect(
      await container.read(calorieLimitRepositoryProvider).load(),
      CalorieLimit.defaultValue,
    );

    await signOut(container);
    await signIn(container, 'a@example.com');

    final mealsAgain = await container.read(mealRepositoryProvider.future);
    expect((await mealsAgain.mealsOn(day)).single.name, 'Oat bowl');
    expect(await container.read(calorieLimitRepositoryProvider).load(), 1800);
  });

  test('meals saved before accounts go to the first account', () async {
    await database.insert('meals', {
      'name': 'Toast',
      'calories': 180,
      'eaten_at': DateTime(2026, 9, 10, 8).toUtc().millisecondsSinceEpoch,
    });
    final container = await newContainer();

    await signIn(container, 'a@example.com');
    final mealsOfA = await container.read(mealRepositoryProvider.future);
    expect((await mealsOfA.mealsOn(day)).single.name, 'Toast');

    await signOut(container);
    await signIn(container, 'b@example.com');

    final mealsOfB = await container.read(mealRepositoryProvider.future);
    expect(await mealsOfB.mealsOn(day), isEmpty);
  });
}
