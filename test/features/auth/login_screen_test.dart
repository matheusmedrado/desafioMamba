import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/app/placeholder_home.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/login_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MambaApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows validation errors before signing in', (tester) async {
    await pumpApp(tester);
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('valid credentials sign in and survive a restart', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderHome), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);

    // A new ProviderScope with the same storage behaves like a cold start.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);

    expect(find.byType(PlaceholderHome), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
