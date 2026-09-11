import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import 'home_shell.dart';

/// Picks the first screen from the persisted session.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    return switch (session) {
      AsyncData(:final value) when value != null => const HomeShell(),
      AsyncData() || AsyncError() => const LoginScreen(),
      _ => const Scaffold(body: SizedBox.expand()),
    };
  }
}
