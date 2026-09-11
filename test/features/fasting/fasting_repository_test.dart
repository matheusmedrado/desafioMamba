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

  FastingSession sessionWithId(String id) => FastingSession.start(
    id: id,
    protocolId: '18:6',
    target: const Duration(hours: 18),
    startedAt: DateTime.utc(2026, 9, 10, 8),
  );

  test('saves and loads the active session', () async {
    final repository = FastingRepository(SharedPreferencesAsync());
    final session = sessionWithId('fast-1');

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

  test('removes a stored value that is not a JSON object', () async {
    final prefs = SharedPreferencesAsync();
    final repository = FastingRepository(prefs);
    await prefs.setString('fasting.active_session', '[1, 2, 3]');

    expect(await repository.load(), isNull);
    expect(await prefs.getString('fasting.active_session'), isNull);
  });

  test('each account keeps its own active session', () async {
    final prefs = SharedPreferencesAsync();
    final mine = FastingRepository(prefs, userId: 'user-1');
    final other = FastingRepository(prefs, userId: 'user-2');

    await mine.save(sessionWithId('mine'));
    await other.save(sessionWithId('theirs'));

    expect((await mine.load())?.id, 'mine');
    expect((await other.load())?.id, 'theirs');

    await mine.clear();
    expect(await mine.load(), isNull);
    expect((await other.load())?.id, 'theirs');
  });

  test('a session saved before accounts goes to the first account', () async {
    final prefs = SharedPreferencesAsync();
    final session = sessionWithId('fast-1');
    await FastingRepository(prefs).save(session);

    final first = FastingRepository(prefs, userId: 'user-1');
    expect(await first.load(), session);
    expect(await prefs.getString(FastingRepository.baseKey), isNull);

    final second = FastingRepository(prefs, userId: 'user-2');
    expect(await second.load(), isNull);
    expect(await first.load(), session);
  });
}
