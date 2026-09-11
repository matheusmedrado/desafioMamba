import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/formatting.dart';

void main() {
  test('formatDayLabel uses the weekday, day, and short month', () {
    expect(formatDayLabel(DateTime(2026, 9, 9, 16, 20)), 'Wednesday, 9 Sep');
    expect(formatDayLabel(DateTime(2026, 1, 31)), 'Saturday, 31 Jan');
  });

  test('formatWeekdayShort uses three letters', () {
    expect(formatWeekdayShort(DateTime(2026, 9, 8)), 'Tue');
    expect(formatWeekdayShort(DateTime(2026, 9, 13)), 'Sun');
  });

  test('formatClockTime pads hours and minutes', () {
    expect(formatClockTime(DateTime(2026, 9, 9, 7, 5)), '07:05');
    expect(formatClockTime(DateTime(2026, 9, 9, 16, 20)), '16:20');
  });

  test('formatHoursMinutes pads minutes and drops seconds', () {
    expect(formatHoursMinutes(Duration.zero), '0h 00m');
    expect(
      formatHoursMinutes(const Duration(minutes: 5, seconds: 59)),
      '0h 05m',
    );
    expect(
      formatHoursMinutes(const Duration(hours: 16, minutes: 30)),
      '16h 30m',
    );
  });

  test('formatThousands groups digits by three', () {
    expect(formatThousands(0), '0');
    expect(formatThousands(999), '999');
    expect(formatThousands(1240), '1,240');
    expect(formatThousands(1234567), '1,234,567');
  });
}
