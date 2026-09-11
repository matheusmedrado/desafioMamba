import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/theme.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/widgets/fasting_path.dart';

void main() {
  test('the head starts at the beginning of the route facing right', () {
    final head = FastingPathPainter.headAt(0);

    expect(head.position.dx, closeTo(20, 0.01));
    expect(head.position.dy, closeTo(24, 0.01));
    expect(head.angle, closeTo(0, 0.01));
  });

  test('the head ends at the end of the route facing right', () {
    final head = FastingPathPainter.headAt(1);

    expect(head.position.dx, closeTo(312, 0.01));
    expect(head.position.dy, closeTo(132, 0.01));
    expect(head.angle, closeTo(0, 0.01));
  });

  test('halfway the head is on the middle straight facing left', () {
    final head = FastingPathPainter.headAt(0.5);

    expect(head.position.dy, closeTo(82, 0.5));
    expect(head.angle.abs(), closeTo(math.pi, 0.01));
  });

  test('progress outside 0 to 1 is clamped', () {
    expect(
      FastingPathPainter.headAt(1.5).position,
      FastingPathPainter.headAt(1).position,
    );
    expect(
      FastingPathPainter(
        progress: -1,
        trackColor: MambaColors.pathTrack,
      ).progress,
      0,
    );
  });

  test('repaints only when progress or track color changes', () {
    final painter = FastingPathPainter(
      progress: 0.3,
      trackColor: MambaColors.pathTrack,
    );

    expect(
      painter.shouldRepaint(
        FastingPathPainter(progress: 0.3, trackColor: MambaColors.pathTrack),
      ),
      isFalse,
    );
    expect(
      painter.shouldRepaint(
        FastingPathPainter(progress: 0.4, trackColor: MambaColors.pathTrack),
      ),
      isTrue,
    );
  });

  testWidgets('renders at the requested height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FastingPath(progress: 0.4, height: 132)),
      ),
    );

    expect(tester.getSize(find.byType(FastingPath)).height, 132);
  });
}
