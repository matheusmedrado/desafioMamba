import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user_session.dart';

/// Owns the persisted user session.
class SessionRepository {
  SessionRepository(this._prefs);

  static const _key = 'auth.session';

  final SharedPreferencesAsync _prefs;

  Future<UserSession?> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return UserSession.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      // A corrupted record is treated as signed out rather than crashing.
      await _prefs.remove(_key);
      return null;
    } on TypeError {
      await _prefs.remove(_key);
      return null;
    }
  }

  Future<void> save(UserSession session) {
    return _prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<void> clear() => _prefs.remove(_key);
}

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(sharedPreferencesProvider)),
);
