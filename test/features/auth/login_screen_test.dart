import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/login_screen.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_home_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../fasting/fake_fasting_notification_service.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database database;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    // The isolate-based factory does not complete inside the fake async zone
    // that widget tests run in.
    database = await AppDatabase.open(
      databaseFactoryFfiNoIsolate,
      inMemoryDatabasePath,
    );
  });

  tearDown(() => database.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    expect(find.byType(FastingHomeScreen), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);

    // A new ProviderScope with the same storage behaves like a cold start.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);

    expect(find.byType(FastingHomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
