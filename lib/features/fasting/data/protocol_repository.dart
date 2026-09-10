import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/data/session_repository.dart';
import '../domain/fasting_protocol.dart';

/// Owns the persisted protocol choice.
class ProtocolRepository {
  ProtocolRepository(this._prefs);

  static const _key = 'fasting.protocol';

  final SharedPreferencesAsync _prefs;

  Future<ProtocolSettings> load() async {
    final raw = await _prefs.getString(_key);
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
}

final protocolRepositoryProvider = Provider<ProtocolRepository>(
  (ref) => ProtocolRepository(ref.watch(sharedPreferencesProvider)),
);
