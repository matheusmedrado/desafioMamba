import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/auth/data/session_repository.dart';
import 'package:mamba_fast_tracker/features/auth/domain/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SessionRepository repository;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    repository = SessionRepository(SharedPreferencesAsync());
  });

  test('returns null when nothing is stored', () async {
    expect(await repository.load(), isNull);
  });

  test('round trips a session', () async {
    final session = UserSession(
      email: 'user@example.com',
      signedInAt: DateTime.utc(2026, 9, 9, 12, 30),
    );

    await repository.save(session);

    expect(await repository.load(), session);
  });

  test('clear removes the session', () async {
    await repository.save(
      UserSession(email: 'user@example.com', signedInAt: DateTime.utc(2026)),
    );

    await repository.clear();

    expect(await repository.load(), isNull);
  });

  test('treats a corrupted record as signed out', () async {
    await SharedPreferencesAsync().setString('auth.session', '{not json');

    expect(await repository.load(), isNull);
  });
}
