import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';

void main() {
  FastingSession startedFast(int targetHours) => FastingSession.start(
    id: 'fast-1',
    protocolId: '$targetHours:${24 - targetHours}',
    target: Duration(hours: targetHours),
    startedAt: DateTime.utc(2026, 9, 10, 20),
  );

  test('the eating window closes after the rest of 24 hours', () {
    final ended = startedFast(16).endAt(DateTime.utc(2026, 9, 11, 12, 4));

    expect(ended.eatingWindowEndsAt, DateTime.utc(2026, 9, 11, 20, 4));
  });

  test('a longer fast leaves a shorter eating window', () {
    final ended = startedFast(23).endAt(DateTime.utc(2026, 9, 11, 19));

    expect(ended.eatingWindowEndsAt, DateTime.utc(2026, 9, 11, 20));
  });

  test('a fast that has not ended has no eating window yet', () {
    expect(startedFast(16).eatingWindowEndsAt, isNull);
  });
}
