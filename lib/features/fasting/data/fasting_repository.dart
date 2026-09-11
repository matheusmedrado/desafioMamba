import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/fasting_session.dart';

/// Owns the persisted current fasting session of one user.
class FastingRepository {
  FastingRepository(this._prefs, {this.userId = ''});

  static const baseKey = 'fasting.active_session';

  final SharedPreferencesAsync _prefs;
  final String userId;

  String get _key => userKey(baseKey, userId);

  Future<FastingSession?> load() async {
    final raw = await _read();
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

  Future<String?> _read() async {
    final raw = await _prefs.getString(_key);
    if (raw != null || userId.isEmpty) return raw;

    final savedBeforeAccounts = await _prefs.getString(baseKey);
    if (savedBeforeAccounts == null) return null;
    await _prefs.setString(_key, savedBeforeAccounts);
    await _prefs.remove(baseKey);
    return savedBeforeAccounts;
  }
}

final fastingRepositoryProvider = Provider<FastingRepository>(
  (ref) => FastingRepository(
    ref.watch(sharedPreferencesProvider),
    userId: ref.watch(currentUserIdProvider),
  ),
);
