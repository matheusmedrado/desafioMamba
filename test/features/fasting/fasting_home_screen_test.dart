import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_controller.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_home_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fake_fasting_notification_service.dart';

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

  Future<ProviderContainer> pumpFastingScreen(
    WidgetTester tester,
    FakeClock clock,
  ) async {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        databaseProvider.overrideWith((ref) => database),
        fastingNotificationServiceProvider.overrideWithValue(
          RecordingFastingNotificationService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildMambaTheme(),
          home: const FastingHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('starts, pauses, resumes, and ends a fast', (tester) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pumpFastingScreen(tester, clock);

    expect(find.text('Start fast'), findsOneWidget);
    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();

    expect(find.text('Pause fast'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);

    await tester.tap(find.text('Pause fast'));
    await tester.pumpAndSettle();
    expect(find.text('Resume fast'), findsOneWidget);

    await tester.tap(find.text('Resume fast'));
    await tester.pumpAndSettle();
    expect(find.text('Pause fast'), findsOneWidget);

    await tester.tap(find.text('End fast'));
    await tester.pumpAndSettle();
    expect(find.text('Fast ended'), findsOneWidget);
    expect(find.text('Start new fast'), findsOneWidget);
  });

  testWidgets('the ticker refreshes elapsed and remaining time', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pumpFastingScreen(tester, clock);

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();
    expect(find.text('16:00:00'), findsOneWidget);

    clock.advance(const Duration(minutes: 5));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('00:05:00'), findsWidgets);
    expect(find.text('15:55:00'), findsOneWidget);

    await tester.tap(find.text('End fast'));
    await tester.pumpAndSettle();
  });

  testWidgets('returning to the foreground shows time passed in background', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pumpFastingScreen(tester, clock);

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    clock.advance(const Duration(hours: 17));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    // Let restore() finish reading storage without firing the ticker.
    await tester.pump();
    await tester.pump();

    expect(find.text('17:00:00'), findsWidgets);
    expect(find.text('Goal reached'), findsOneWidget);

    await tester.tap(find.text('End fast'));
    await tester.pumpAndSettle();
  });

  testWidgets('removing the timer screen disposes the running ticker', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final container = await pumpFastingScreen(tester, clock);

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();
    expect(container.exists(fastingControllerProvider), isTrue);

    // Logout replaces the timer screen while the fast is still running.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SizedBox()),
      ),
    );
    await tester.pump();

    expect(container.exists(fastingControllerProvider), isFalse);
  });
}
