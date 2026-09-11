import 'dart:async';

import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/domain/auth_failure.dart';
import 'package:mamba_fast_tracker/features/auth/domain/auth_user.dart';

/// In-memory accounts that keep the session like Firebase Auth does.
class FakeAuthRepository implements AuthRepository {
  final _passwords = <String, String>{};
  final _changes = StreamController<AuthUser?>.broadcast();
  final resetRequests = <String>[];
  AuthUser? _current;

  void addAccount(String email, String password) {
    _passwords[email] = password;
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    StreamSubscription<AuthUser?>? changes;
    late final StreamController<AuthUser?> controller;
    // Subscribe on listen so no change is missed after the current value.
    controller = StreamController<AuthUser?>(
      onListen: () {
        controller.add(_current);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (_passwords[email] != password) throw AuthFailure.invalidCredentials;
    _setCurrent(email);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    if (_passwords.containsKey(email)) throw AuthFailure.emailInUse;
    _passwords[email] = password;
    _setCurrent(email);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetRequests.add(email);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _changes.add(null);
  }

  void _setCurrent(String email) {
    _current = AuthUser(id: 'uid-$email', email: email);
    _changes.add(_current);
  }
}
