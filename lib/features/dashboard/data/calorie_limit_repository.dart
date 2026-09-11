import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/data/session_repository.dart';
import '../domain/calorie_limit.dart';

/// Owns the persisted daily calorie limit.
class CalorieLimitRepository {
  CalorieLimitRepository(this._prefs);

  static const _key = 'dashboard.calorie_limit';

  final SharedPreferencesAsync _prefs;

  /// The saved limit, or the default when none is saved or the stored value
  /// is not a valid limit.
  Future<int> load() async {
    try {
      final limit = await _prefs.getInt(_key);
      return limit != null && CalorieLimit.isValid(limit)
          ? limit
          : CalorieLimit.defaultValue;
    } on TypeError {
      return CalorieLimit.defaultValue;
    }
  }

  Future<void> save(int limit) async {
    if (!CalorieLimit.isValid(limit)) {
      throw ArgumentError.value(
        limit,
        'limit',
        'must be between ${CalorieLimit.min} and ${CalorieLimit.max}',
      );
    }
    await _prefs.setInt(_key, limit);
  }
}

final calorieLimitRepositoryProvider = Provider<CalorieLimitRepository>(
  (ref) => CalorieLimitRepository(ref.watch(sharedPreferencesProvider)),
);
