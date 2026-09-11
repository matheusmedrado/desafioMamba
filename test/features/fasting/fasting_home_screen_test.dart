import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/home_shell.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/end_fast_sheet.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_controller.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_home_screen.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/meals_screen.dart';
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
    // The isolate-based factory does not complete in the widget test zone.
    database = await AppDatabase.open(
      databaseFactoryFfiNoIsolate,
      inMemoryDatabasePath,
    );
  });

  tearDown(() => database.close());

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakeClock clock, {
    Widget home = const FastingHomeScreen(),
  }) async {
    tester.view.physicalSize = const Size(1080, 2430);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

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
        child: MaterialApp(theme: buildMambaTheme(), home: home),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> confirmEnd(WidgetTester tester) async {
    await tester.tap(find.text('End fast'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(EndFastSheet.confirmKey));
    await tester.pumpAndSettle();
  }

  testWidgets('starts, pauses, resumes, and ends a fast', (tester) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pump(tester, clock);

    expect(find.text('Your next fast'), findsOneWidget);
    expect(find.text('16:00'), findsOneWidget);
    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();

    expect(find.text('Fasting now'), findsOneWidget);
    expect(find.text('16h 00m remaining'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsWidgets);
    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('Fasting now'), findsOneWidget);

    clock.advance(const Duration(hours: 2));
    await confirmEnd(tester);
    expect(find.text('Fast complete.'), findsOneWidget);

    await tester.tap(find.text('Back to Today'));
    await tester.pumpAndSettle();
    expect(find.text('Your next fast'), findsOneWidget);
    expect(find.text('Start fast'), findsOneWidget);
  });

  testWidgets('ending early warns, and keep fasting leaves it running', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pump(tester, clock);

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();
    clock.advance(const Duration(hours: 5, minutes: 42));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('End fast'));
    await tester.pumpAndSettle();
    expect(find.text('End this fast?'), findsOneWidget);
    expect(find.textContaining('short of your 16h goal'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(EndFastSheet),
        matching: find.text('5h 42m'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Keep fasting'));
    await tester.pumpAndSettle();
    expect(find.text('End this fast?'), findsNothing);
    expect(find.text('Fasting now'), findsOneWidget);

    await confirmEnd(tester);
    expect(find.text('Ended early'), findsOneWidget);
    expect(find.text('36% of 16h'), findsOneWidget);
    expect(find.text('Started'), findsOneWidget);
    expect(find.text('Eating window'), findsOneWidget);

    await tester.tap(find.text('Back to Today'));
    await tester.pumpAndSettle();
  });

  testWidgets('the ticker refreshes elapsed and remaining time', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pump(tester, clock);

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();
    expect(find.text('00:00'), findsOneWidget);

    clock.advance(const Duration(minutes: 5, seconds: 7));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('00:05'), findsOneWidget);
    expect(find.text(':07'), findsOneWidget);
    expect(find.text('15h 54m remaining'), findsOneWidget);
    expect(find.text('1% of 16h goal'), findsOneWidget);

    await confirmEnd(tester);
    await tester.tap(find.text('Back to Today'));
    await tester.pumpAndSettle();
  });

  testWidgets('returning to the foreground shows time passed in background', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pump(tester, clock);

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    clock.advance(const Duration(hours: 17));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    // Let restore() finish reading storage without firing the ticker.
    await tester.pump();
    await tester.pump();

    expect(find.text('17:00'), findsOneWidget);
    expect(find.text('Goal reached'), findsOneWidget);
    expect(find.text('100% of 16h goal'), findsOneWidget);

    await tester.tap(find.text('End fast'));
    await tester.pumpAndSettle();
    expect(find.textContaining('short of'), findsNothing);
    await tester.tap(find.byKey(EndFastSheet.confirmKey));
    await tester.pumpAndSettle();

    expect(find.text('Fast complete.'), findsOneWidget);
    expect(find.text('Goal reached'), findsOneWidget);
    expect(find.text('16h goal'), findsOneWidget);

    await tester.tap(find.text('Back to Today'));
    await tester.pumpAndSettle();
  });

  testWidgets('log a meal opens the Meals tab', (tester) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    await pump(tester, clock, home: const HomeShell());

    await tester.tap(find.text('Start fast'));
    await tester.pumpAndSettle();
    clock.advance(const Duration(hours: 1));
    await confirmEnd(tester);

    await tester.tap(find.text('Log a meal'));
    await tester.pumpAndSettle();

    expect(find.byType(MealsScreen), findsOneWidget);
    expect(find.text('No meals yet'), findsOneWidget);
  });

  testWidgets('removing the timer screen disposes the running ticker', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final container = await pump(tester, clock);

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
