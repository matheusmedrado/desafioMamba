import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

/// The signed-in account, restored by Firebase after a restart.
class AuthController extends StreamNotifier<AuthUser?> {
  @override
  Stream<AuthUser?> build() {
    return ref.watch(authRepositoryProvider).authStateChanges();
  }

  Future<void> signIn({required String email, required String password}) {
    return ref
        .read(authRepositoryProvider)
        .signIn(email: _normalize(email), password: password);
  }

  Future<void> signUp({required String email, required String password}) {
    return ref
        .read(authRepositoryProvider)
        .signUp(email: _normalize(email), password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return ref
        .read(authRepositoryProvider)
        .sendPasswordReset(_normalize(email));
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();

  static String _normalize(String email) => email.trim().toLowerCase();
}

final authControllerProvider =
    StreamNotifierProvider<AuthController, AuthUser?>(AuthController.new);

/// Owner of the stored data. Empty while signed out, which is also how data
/// saved before accounts existed is stored.
final currentUserIdProvider = Provider<String>(
  (ref) => ref.watch(authControllerProvider).value?.id ?? '',
);
