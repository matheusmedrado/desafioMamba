import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/login_screen.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_home_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../fasting/fake_fasting_notification_service.dart';
import 'fake_auth_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;
  late FakeAuthRepository accounts;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    accounts = FakeAuthRepository();
    // The isolate-based factory does not complete in the widget test zone.
    database = await AppDatabase.open(
      databaseFactoryFfiNoIsolate,
      inMemoryDatabasePath,
    );
  });

  tearDown(() => database.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2430);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(accounts),
          databaseProvider.overrideWith((ref) => database),
          fastingNotificationServiceProvider.overrideWithValue(
            RecordingFastingNotificationService(),
          ),
        ],
        child: const MambaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, List<String> values) async {
    for (final (index, value) in values.indexed) {
      await tester.enterText(find.byType(TextFormField).at(index), value);
    }
  }

  testWidgets('shows validation errors before signing in', (tester) async {
    await pumpApp(tester);
    expect(find.byType(LoginScreen), findsOneWidget);

    await tapText(tester, 'Log in');

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('creating an account signs in and survives a restart', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, 'Create an account');
    expect(find.text('Start your rhythm.'), findsOneWidget);

    await fill(tester, ['user@example.com', 'password1', 'password1']);
    await tapText(tester, 'Create account');

    expect(find.byType(FastingHomeScreen), findsOneWidget);

    // A new ProviderScope with the same accounts behaves like a cold start.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);

    expect(find.byType(FastingHomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('creating an account needs matching passwords', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Create an account');

    await fill(tester, ['user@example.com', 'password1', 'password2']);
    await tapText(tester, 'Create account');

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a wrong password shows a clear message', (tester) async {
    accounts.addAccount('user@example.com', 'password1');
    await pumpApp(tester);

    await fill(tester, ['user@example.com', 'password2']);
    await tapText(tester, 'Log in');

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('forgot password sends a reset link to the typed email', (
    tester,
  ) async {
    await pumpApp(tester);
    await fill(tester, ['user@example.com']);

    await tapText(tester, 'Forgot password?');
    expect(find.text('Reset your password'), findsOneWidget);
    await tapText(tester, 'Send reset link');

    expect(accounts.resetRequests, ['user@example.com']);
    expect(
      find.text(
        'If an account exists for this email, a reset link is on its way.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('log out from the settings sheet returns to login', (
    tester,
  ) async {
    accounts.addAccount('user@example.com', 'password1');
    await pumpApp(tester);
    await fill(tester, ['user@example.com', 'password1']);
    await tapText(tester, 'Log in');

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('user@example.com'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
