import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:mamba_fast_tracker/features/dashboard/presentation/day_summary_section.dart';
import 'package:mamba_fast_tracker/features/fasting/data/completed_fast_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
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
    // The isolate-based factory does not complete inside the fake async zone
    // that widget tests run in.
    database = await AppDatabase.open(
      databaseFactoryFfiNoIsolate,
      inMemoryDatabasePath,
    );
  });

  tearDown(() => database.close());

  Future<void> pumpSection(WidgetTester tester, FakeClock clock) async {
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue(''),
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
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(24),
              child: DaySummarySection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('before any fast ends, today is in progress', (tester) async {
    await pumpSection(tester, FakeClock(DateTime(2026, 9, 10, 9)));

    expect(find.text('Your day'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('0 / 2,000 kcal'), findsOneWidget);
    expect(find.text('0h 00m'), findsOneWidget);
  });

  testWidgets('shows stored totals and updates when the limit changes', (
    tester,
  ) async {
    await MealRepository(
      database,
      '',
    ).add(name: 'Pasta', calories: 1500, eatenAt: DateTime(2026, 9, 10, 12));
    await CompletedFastRepository(database, '').save(
      FastingSession.start(
        id: 'fast-1',
        protocolId: '16:8',
        target: const Duration(hours: 16),
        startedAt: DateTime(2026, 9, 9, 20),
      ).endAt(DateTime(2026, 9, 10, 12, 30)),
    );
    await pumpSection(tester, FakeClock(DateTime(2026, 9, 10, 18)));

    expect(find.text('Within goal'), findsOneWidget);
    expect(find.text('1,500 / 2,000 kcal'), findsOneWidget);
    expect(find.text('16h 30m'), findsOneWidget);

    await tester.tap(find.byTooltip('Change calorie limit'));
    await tester.pumpAndSettle();
    expect(find.text('Daily calorie limit'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '100');
    await tester.tap(find.text('Save limit'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a whole number between 500 and 5,000.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), '1000');
    await tester.tap(find.text('Save limit'));
    await tester.pumpAndSettle();

    expect(find.text('Outside goal'), findsOneWidget);
    expect(find.text('1,500 / 1,000 kcal'), findsOneWidget);
    expect(find.text('Over your calorie limit by 500 kcal.'), findsOneWidget);
  });

  testWidgets('closing the limit sheet without saving keeps the limit', (
    tester,
  ) async {
    await pumpSection(tester, FakeClock(DateTime(2026, 9, 10, 9)));

    await tester.tap(find.byTooltip('Change calorie limit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '500');

    // The keyboard closing does not submit the form.
    tester.testTextInput.closeConnection();
    await tester.pumpAndSettle();
    expect(find.text('Daily calorie limit'), findsOneWidget);

    // Android back closes the sheet without saving.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Daily calorie limit'), findsNothing);
    expect(find.text('0 / 2,000 kcal'), findsOneWidget);
  });

  testWidgets('the keyboard Done action saves the limit', (tester) async {
    await pumpSection(tester, FakeClock(DateTime(2026, 9, 10, 9)));

    await tester.tap(find.byTooltip('Change calorie limit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1800');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Daily calorie limit'), findsNothing);
    expect(find.text('0 / 1,800 kcal'), findsOneWidget);
  });
}
