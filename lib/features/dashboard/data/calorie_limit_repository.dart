import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/calorie_limit.dart';

/// Owns the persisted daily calorie limit of one user.
class CalorieLimitRepository {
  CalorieLimitRepository(this._prefs, {this.userId = ''});

  static const baseKey = 'dashboard.calorie_limit';

  final SharedPreferencesAsync _prefs;
  final String userId;

  String get _key => userKey(baseKey, userId);

  /// The saved limit, or the default when none is saved or the stored value
  /// is not a valid limit.
  Future<int> load() async {
    try {
      final limit = await _read();
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

  Future<int?> _read() async {
    final limit = await _prefs.getInt(_key);
    if (limit != null || userId.isEmpty) return limit;

    final savedBeforeAccounts = await _prefs.getInt(baseKey);
    if (savedBeforeAccounts == null) return null;
    await _prefs.setInt(_key, savedBeforeAccounts);
    await _prefs.remove(baseKey);
    return savedBeforeAccounts;
  }
}

final calorieLimitRepositoryProvider = Provider<CalorieLimitRepository>(
  (ref) => CalorieLimitRepository(
    ref.watch(sharedPreferencesProvider),
    userId: ref.watch(currentUserIdProvider),
  ),
);
