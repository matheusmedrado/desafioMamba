import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/home_shell.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/auth_controller.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/meals/presentation/meals_screen.dart';
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

  Future<void> pump(WidgetTester tester, Widget home, FakeClock clock) async {
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
        child: MaterialApp(theme: buildMambaTheme(), home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('adds, edits, and deletes a meal', (tester) async {
    final clock = FakeClock(DateTime(2026, 9, 10, 12, 30));
    await pump(tester, const MealsScreen(), clock);

    expect(find.text('Thursday, 10 Sep'), findsOneWidget);
    expect(find.text('No meals yet'), findsOneWidget);

    await tester.tap(find.text('Add meal'));
    await tester.pumpAndSettle();
    expect(find.text('Time 12:30 · recorded automatically'), findsOneWidget);

    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();
    expect(find.text('Give the meal a name.'), findsOneWidget);
    expect(
      find.text('Enter a whole number between 1 and 5,000.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Oat bowl');
    await tester.enterText(find.byType(TextFormField).at(1), '1240');
    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();

    expect(find.text('Oat bowl'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);
    expect(find.text('1,240 kcal'), findsNWidgets(2));
    expect(find.text('1 meal · last at 12:30'), findsOneWidget);
    expect(find.text('Meal added'), findsOneWidget);

    await tester.tap(find.text('Oat bowl'));
    await tester.pumpAndSettle();
    expect(find.text('Edit meal'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), '520');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('520 kcal'), findsNWidgets(2));
    expect(find.text('Meal updated'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit Oat bowl'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this meal?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No meals yet'), findsOneWidget);
    expect(find.text('Meal deleted'), findsOneWidget);
  });

  testWidgets('cancelling a delete returns to the edit form', (tester) async {
    final clock = FakeClock(DateTime(2026, 9, 10, 8));
    await pump(tester, const MealsScreen(), clock);

    await tester.tap(find.text('Add meal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Toast');
    await tester.enterText(find.byType(TextFormField).at(1), '180');
    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Toast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Edit meal'), findsOneWidget);
    expect(find.text('Toast'), findsWidgets);
  });

  testWidgets('the Meals tab opens from the bottom navigation', (tester) async {
    final clock = FakeClock(DateTime(2026, 9, 10, 8));
    await pump(tester, const HomeShell(), clock);

    expect(find.byType(MealsScreen), findsNothing);

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    expect(find.byType(MealsScreen), findsOneWidget);
    expect(find.text('No meals yet'), findsOneWidget);

    // Inside the tab shell, the confirmation must not cover Add meal.
    await tester.tap(find.text('Add meal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Toast');
    await tester.enterText(find.byType(TextFormField).at(1), '180');
    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();

    expect(find.text('Meal added'), findsOneWidget);
    final snackBar = tester.getRect(find.byType(SnackBar));
    final addButton = tester.getRect(find.byType(FloatingActionButton));
    expect(snackBar.overlaps(addButton), isFalse);
  });
}
