import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key holding [base] for one user. Records saved before accounts existed use
/// the base key itself, and the first account that signs in takes them over.
String userKey(String base, String userId) =>
    userId.isEmpty ? base : '$base.$userId';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);
