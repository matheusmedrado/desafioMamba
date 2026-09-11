import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';

import '../features/auth/fake_auth_repository.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MambaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a device in Portuguese sees the app in Portuguese', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('pt', 'BR'));

    expect(find.text('De volta ao seu ritmo.'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Esqueceu a senha?'), findsOneWidget);
  });

  testWidgets('a device in another language sees English', (tester) async {
    await pumpApp(tester, const Locale('fr'));

    expect(find.text('Back to your rhythm.'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
