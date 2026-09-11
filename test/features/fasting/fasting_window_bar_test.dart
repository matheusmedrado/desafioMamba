import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/l10n/app_localizations.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/widgets/fasting_window_bar.dart';

void main() {
  testWidgets('draws the fasting share of the day at the bar height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildMambaTheme(),
        home: const Center(
          child: SizedBox(
            width: 240,
            child: FastingWindowBar(
              fastingHours: 16,
              fastingLabel: '16h fast',
              eatingLabel: '8h eating',
              height: 18,
              fillColor: MambaColors.purpleDeep,
              trackColor: MambaColors.surfaceHover,
            ),
          ),
        ),
      ),
    );

    Size sizeOf(Color color) => tester.getSize(
      find.byWidgetPredicate((w) => w is ColoredBox && w.color == color),
    );

    expect(sizeOf(MambaColors.purpleDeep), const Size(160, 18));
    expect(sizeOf(MambaColors.surfaceHover), const Size(80, 18));
  });
}
