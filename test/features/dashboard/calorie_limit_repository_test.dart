import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/dashboard/data/calorie_limit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('uses 2,000 kcal when no limit was saved', () async {
    expect(await CalorieLimitRepository(SharedPreferencesAsync()).load(), 2000);
  });

  test('saves and loads a limit', () async {
    final repository = CalorieLimitRepository(SharedPreferencesAsync());

    await repository.save(1800);

    expect(await repository.load(), 1800);
  });

  test('falls back to the default when the stored limit is invalid', () async {
    final prefs = SharedPreferencesAsync();
    await prefs.setInt('dashboard.calorie_limit', 12);

    expect(await CalorieLimitRepository(prefs).load(), 2000);
  });

  test('refuses to save a limit outside the allowed range', () async {
    final repository = CalorieLimitRepository(SharedPreferencesAsync());

    expect(() => repository.save(100), throwsArgumentError);
    expect(await repository.load(), 2000);
  });
}
