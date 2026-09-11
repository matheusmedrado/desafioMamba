import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/login_screen.dart';

import '../features/auth/fake_auth_repository.dart';

void main() {
  testWidgets('app starts signed out with the project theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MambaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.scaffoldBackgroundColor, MambaColors.background);
    expect(materialApp.theme?.textTheme.bodyLarge?.fontFamily, 'Manrope');
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
