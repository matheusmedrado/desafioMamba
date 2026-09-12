import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/l10n/app_localizations.dart';
import 'package:mamba_fast_tracker/app/home_shell.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:mamba_fast_tracker/features/fasting/data/completed_fast_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/history/presentation/history_screen.dart';
import 'package:mamba_fast_tracker/features/meals/data/meal_repository.dart';
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
    // The isolate-based factory does not complete in the widget test zone.
    database = await AppDatabase.open(
      databaseFactoryFfiNoIsolate,
      inMemoryDatabasePath,
    );
  });

  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester, Widget home) async {
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue(''),
        clockProvider.overrideWithValue(FakeClock(DateTime(2026, 9, 10, 18))),
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildMambaTheme(),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('today is not listed, so a new user sees the empty state', (
    tester,
  ) async {
    await MealRepository(
      database,
      '',
    ).add(name: 'Toast', calories: 300, eatenAt: DateTime(2026, 9, 10, 8));
    await pump(tester, const HistoryScreen());

    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('lists previous days and opens a day summary', (tester) async {
    final meals = MealRepository(database, '');
    await meals.add(
      name: 'Pasta',
      calories: 1800,
      eatenAt: DateTime(2026, 9, 9, 13),
    );
    await meals.add(
      name: 'Pizza',
      calories: 2500,
      eatenAt: DateTime(2026, 9, 1, 19),
    );
    await CompletedFastRepository(database, '').save(
      FastingSession.start(
        id: 'fast-1',
        protocolId: '16:8',
        target: const Duration(hours: 16),
        startedAt: DateTime(2026, 9, 8, 20),
      ).endAt(DateTime(2026, 9, 9, 12, 30)),
    );
    await pump(tester, const HistoryScreen());

    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('LAST WEEK'), findsOneWidget);
    expect(find.text('16h 30m fast'), findsOneWidget);
    expect(find.text('16:8 · 1,800 kcal'), findsOneWidget);
    expect(find.byTooltip('Within goal'), findsOneWidget);
    expect(find.text('No fast'), findsOneWidget);
    expect(find.text('2,500 kcal'), findsOneWidget);
    expect(find.byTooltip('No fast'), findsOneWidget);

    await tester.tap(find.text('16h 30m fast'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, 9 Sep'), findsOneWidget);
    expect(find.text('Within goal'), findsOneWidget);
    expect(find.text('Goal reached'), findsOneWidget);
    expect(find.text('Started 20:00 Tue'), findsOneWidget);
    expect(find.text('Ended 12:30'), findsOneWidget);
    expect(find.text('+0h 30m'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('1,800 / 2,000 kcal'), findsOneWidget);
  });

  testWidgets('the History tab opens from the bottom navigation', (
    tester,
  ) async {
    await pump(tester, const HomeShell());
    expect(find.byType(HistoryScreen), findsNothing);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });
}
