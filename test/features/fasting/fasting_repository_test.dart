import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('saves and loads the active session', () async {
    final repository = FastingRepository(SharedPreferencesAsync());
    final session = FastingSession.start(
      id: 'fast-1',
      protocolId: '18:6',
      target: const Duration(hours: 18),
      startedAt: DateTime.utc(2026, 9, 10, 8),
    );

    await repository.save(session);

    expect(await repository.load(), session);
  });

  test('removes a malformed active session instead of crashing', () async {
    final prefs = SharedPreferencesAsync();
    final repository = FastingRepository(prefs);
    await prefs.setString(
      'fasting.active_session',
      '{"status":"not-a-status"}',
    );

    expect(await repository.load(), isNull);
    expect(await prefs.getString('fasting.active_session'), isNull);
  });
}
