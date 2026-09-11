import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/fasting_protocol.dart';

/// Owns the persisted protocol choice of one user.
class ProtocolRepository {
  ProtocolRepository(this._prefs, {this.userId = ''});

  static const baseKey = 'fasting.protocol';

  final SharedPreferencesAsync _prefs;
  final String userId;

  String get _key => userKey(baseKey, userId);

  Future<ProtocolSettings> load() async {
    final raw = await _read();
    if (raw == null) return ProtocolSettings.defaults;
    try {
      return ProtocolSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      return ProtocolSettings.defaults;
    } on TypeError {
      return ProtocolSettings.defaults;
    }
  }

  Future<void> save(ProtocolSettings settings) {
    return _prefs.setString(_key, jsonEncode(settings.toJson()));
  }

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

final protocolRepositoryProvider = Provider<ProtocolRepository>(
  (ref) => ProtocolRepository(
    ref.watch(sharedPreferencesProvider),
    userId: ref.watch(currentUserIdProvider),
  ),
);
