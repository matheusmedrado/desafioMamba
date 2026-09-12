import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';

/// Account actions the app needs. Throws [AuthFailure] when an action fails.
abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({required String email, required String password});

  Future<void> sendPasswordReset(String email);

  Future<void> updateName(String name);

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// `userChanges` also emits after a profile change, such as a new name.
  @override
  Stream<AuthUser?> authStateChanges() => _auth.userChanges().map(_toUser);

  @override
  Future<void> signIn({required String email, required String password}) {
    return _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email));
  }

  @override
  Future<void> updateName(String name) {
    return _guard(() async {
      final user = _auth.currentUser;
      if (user == null) throw AuthFailure.unknown;
      await user.updateDisplayName(name.isEmpty ? null : name);
      await user.reload();
    });
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  AuthUser? _toUser(User? user) {
    if (user == null) return null;
    final name = user.displayName;
    return AuthUser(
      id: user.uid,
      email: user.email!,
      name: name == null || name.isEmpty ? null : name,
    );
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromCode(error.code);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);
