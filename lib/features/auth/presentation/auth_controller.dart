import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../data/session_repository.dart';
import '../domain/user_session.dart';

/// Holds the current session. `null` means signed out.
///
/// The initial value is loaded from storage, which is what restores the
/// session after the app is closed and reopened.
class AuthController extends AsyncNotifier<UserSession?> {
  @override
  Future<UserSession?> build() {
    return ref.watch(sessionRepositoryProvider).load();
  }

  /// Local authentication: any input that passed form validation signs in.
  /// The password is not stored or checked against anything.
  Future<void> login({required String email, required String password}) async {
    final session = UserSession(
      email: email.trim().toLowerCase(),
      signedInAt: ref.read(clockProvider).now().toUtc(),
    );
    await ref.read(sessionRepositoryProvider).save(session);
    state = AsyncData(session);
  }

  Future<void> logout() async {
    await ref.read(sessionRepositoryProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserSession?>(AuthController.new);
