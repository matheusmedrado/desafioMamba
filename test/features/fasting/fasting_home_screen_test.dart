import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/core/clock.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/fasting_home_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('starts, pauses, resumes, and ends a fast', (tester) async {
    final clock = FakeClock(DateTime.utc(2026, 9, 10, 8));
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(clock)],
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
}
