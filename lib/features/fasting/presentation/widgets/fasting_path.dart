import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// The winding fasting route, with the head at [progress].
class FastingPath extends StatelessWidget {
  const FastingPath({
    super.key,
    required this.progress,
    this.idle = false,
    this.height = 132,
  });

  final double progress;
  final bool idle;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: FastingPathPainter(
          progress: progress,
          trackColor: idle ? MambaColors.pathTrackIdle : MambaColors.pathTrack,
        ),
      ),
    );
  }
}

class FastingPathPainter extends CustomPainter {
  FastingPathPainter({required double progress, required this.trackColor})
    : progress = progress.clamp(0.0, 1.0);

  static const routeSize = Size(342, 150);

  final double progress;
  final Color trackColor;

  static Path route() => Path()
    ..moveTo(20, 24)
    ..lineTo(275, 24)
    ..cubicTo(326, 24, 326, 82, 275, 82)
    ..lineTo(72, 82)
    ..cubicTo(25, 82, 25, 132, 72, 132)
    ..lineTo(312, 132);

  /// Head position and heading in route coordinates.
  static ({Offset position, double angle}) headAt(double progress) {
    final metric = route().computeMetrics().first;
    final tangent = metric.getTangentForOffset(
      metric.length * progress.clamp(0.0, 1.0),
    )!;
    return (
      position: tangent.position,
      angle: math.atan2(tangent.vector.dy, tangent.vector.dx),
    );
  }

  static final _headShape = Path()
    ..moveTo(-12, -8)
    ..cubicTo(-8, -8, -8, -12, -2, -12)
    ..cubicTo(5, -12, 9, -8, 15, -5)
    ..quadraticBezierTo(18, -3, 18, 0)
    ..quadraticBezierTo(18, 3, 15, 5)
    ..cubicTo(9, 8, 5, 12, -2, 12)
    ..cubicTo(-8, 12, -8, 8, -12, 8)
    ..close();

  static final _headEyes = Path()
    ..moveTo(3, -8)
    ..lineTo(8, -5)
    ..lineTo(5, -4)
    ..lineTo(2, -6)
    ..close()
    ..moveTo(3, 8)
    ..lineTo(8, 5)
    ..lineTo(5, 4)
    ..lineTo(2, 6)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    // Scaled uniformly and centered, so the route keeps its shape.
    final scale = math.min(
      size.width / routeSize.width,
      size.height / routeSize.height,
    );
    canvas
      ..translate(
        (size.width - routeSize.width * scale) / 2,
        (size.height - routeSize.height * scale) / 2,
      )
      ..scale(scale);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = route();
    canvas.drawPath(path, stroke..color = trackColor);

    final metric = path.computeMetrics().first;
    if (progress > 0) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        stroke..color = MambaColors.purpleDeep,
      );
    }

    final head = headAt(progress);
    canvas
      ..save()
      ..translate(head.position.dx, head.position.dy)
      ..rotate(head.angle)
      ..drawPath(_headShape, Paint()..color = MambaColors.yellow)
      ..drawPath(_headEyes, Paint()..color = MambaColors.background)
      ..restore();
  }

  @override
  bool shouldRepaint(FastingPathPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}
