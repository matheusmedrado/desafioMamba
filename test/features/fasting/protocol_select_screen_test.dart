import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/protocol_controller.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/protocol_select_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildMambaTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProtocolSelectScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('selecting a preset and saving persists it', (tester) async {
    final container = await pumpScreen(tester);

    await tester.tap(find.text('18:6'));
    await tester.pump();
    await tester.tap(find.text('Save protocol'));
    await tester.pumpAndSettle();

    expect(find.byType(ProtocolSelectScreen), findsNothing);
    expect(container.read(selectedProtocolProvider), FastingProtocol.advanced);
  });

  testWidgets('custom editor saves hours and closes the flow', (tester) async {
    final container = await pumpScreen(tester);

    await tester.scrollUntilVisible(find.text('Custom'), 200);
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(find.text('Custom protocol'), findsOneWidget);

    // Default is 14. Two taps on increase gives 16.
    await tester.tap(find.byTooltip('Increase Fasting hours'));
    await tester.tap(find.byTooltip('Increase Fasting hours'));
    await tester.pump();
    await tester.tap(find.text('Use this protocol'));
    await tester.pumpAndSettle();

    expect(find.byType(ProtocolSelectScreen), findsNothing);
    expect(
      container.read(selectedProtocolProvider),
      FastingProtocol.custom(16),
    );
  });

  testWidgets('custom stepper stays inside the allowed range', (tester) async {
    await pumpScreen(tester);
    await tester.scrollUntilVisible(find.text('Custom'), 200);
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 20; i++) {
      await tester.tap(
        find.byTooltip('Increase Fasting hours'),
        warnIfMissed: false,
      );
      await tester.pump();
    }

    expect(find.text('23h fasting'), findsOneWidget);
    final increase = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Increase Fasting hours'),
        matching: find.byType(IconButton),
      ),
    );
    expect(increase.onPressed, isNull);
  });
}
