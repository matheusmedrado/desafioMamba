import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/mamba_icon.dart';

void main() {
  testWidgets('every icon renders at the requested size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(
          children: [
            for (final icon in MambaIcons.values) MambaIcon(icon, size: 24),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsNWidgets(MambaIcons.values.length));
    expect(tester.getSize(find.byType(MambaIcon).first), const Size(24, 24));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an icon with a label is announced', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: MambaIcon(MambaIcons.settings, semanticLabel: 'Settings'),
      ),
    );

    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    semantics.dispose();
  });
}
