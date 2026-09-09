import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/clock.dart';

void main() {
  test('fake clock advances only when told to', () {
    final clock = FakeClock(DateTime.utc(2026, 9, 9, 8));

    expect(clock.now(), DateTime.utc(2026, 9, 9, 8));

    clock.advance(const Duration(hours: 16, minutes: 4));
    expect(clock.now(), DateTime.utc(2026, 9, 10, 0, 4));

    clock.set(DateTime.utc(2026, 1, 1));
    expect(clock.now(), DateTime.utc(2026, 1, 1));
  });
}
