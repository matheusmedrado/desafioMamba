import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/app/theme.dart';

void main() {
  testWidgets('app starts with the project theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MambaApp()));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.scaffoldBackgroundColor, MambaColors.background);
    expect(materialApp.theme?.textTheme.bodyLarge?.fontFamily, 'Manrope');
    expect(find.text('FAST TRACKER'), findsOneWidget);
  });
}
