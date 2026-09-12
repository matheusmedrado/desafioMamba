import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/l10n/app_localizations.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:mamba_fast_tracker/features/fasting/data/completed_fast_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/history/presentation/history_screen.dart';
import 'package:mamba_fast_tracker/features/meals/data/meal_repository.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  FastingSession endedFast(String id, DateTime start, DateTime end) {
    return FastingSession.start(
      id: id,
      protocolId: '16:8',
      target: const Duration(hours: 16),
      startedAt: start,
    ).endAt(end);
  }

  testWidgets('shows the week summary on Days and the chart on Week', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await MealRepository(
      database,
      '',
    ).add(name: 'Pasta', calories: 1800, eatenAt: DateTime(2026, 9, 9, 13));
    final fasts = CompletedFastRepository(database, '');
    await fasts.save(
      endedFast(
        'within',
        DateTime(2026, 9, 8, 20),
        DateTime(2026, 9, 9, 12, 30),
      ),
    );
    await fasts.save(
      endedFast('short', DateTime(2026, 9, 7, 20), DateTime(2026, 9, 8, 4)),
    );

    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue(''),
        clockProvider.overrideWithValue(FakeClock(DateTime(2026, 9, 10, 18))),
        databaseProvider.overrideWith((ref) => database),
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
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('1/7 goals'), findsOneWidget);
    expect(find.text('12h 15m'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(find.text('3 – 9 Sep'), findsOneWidget);
    expect(find.text('Fasting hours per day'), findsOneWidget);
    expect(find.text('Daily goal: 16h'), findsOneWidget);
    expect(find.text('17h'), findsOneWidget);
    expect(find.text('8h'), findsWidgets);
    expect(find.bySemanticsLabel('Wed: 16h 30m, goal reached'), findsOneWidget);
    expect(find.bySemanticsLabel('Tue: 8h 00m, short'), findsOneWidget);
    expect(find.bySemanticsLabel('Mon: no fast'), findsOneWidget);
    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('14% of days'), findsOneWidget);
    expect(find.text('16h 30m'), findsOneWidget);
    expect(find.text('Wed 9'), findsOneWidget);

    final note = find.text('You were within goal on 1 of the last 7 days.');
    await tester.scrollUntilVisible(note, 200);
    expect(note, findsOneWidget);

    semantics.dispose();
  });
}
