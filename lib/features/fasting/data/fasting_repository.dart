import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences.dart';
import '../domain/fasting_session.dart';

/// Owns the persisted current fasting session.
class FastingRepository {
  FastingRepository(this._prefs);

  static const _key = 'fasting.active_session';

  final SharedPreferencesAsync _prefs;

  Future<FastingSession?> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null;

    try {
      return FastingSession.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      await _prefs.remove(_key);
      return null;
    } on TypeError {
      await _prefs.remove(_key);
      return null;
    } on ArgumentError {
      await _prefs.remove(_key);
      return null;
    }
  }

  Future<void> save(FastingSession session) {
    return _prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<void> clear() => _prefs.remove(_key);
}

final fastingRepositoryProvider = Provider<FastingRepository>(
  (ref) => FastingRepository(ref.watch(sharedPreferencesProvider)),
);
