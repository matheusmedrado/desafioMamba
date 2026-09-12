import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/formatting.dart';

void main() {
  test('formatDayLabel uses the weekday, day, and short month', () {
    expect(formatDayLabel(DateTime(2026, 9, 9, 16, 20)), 'Wednesday, 9 Sep');
    expect(formatDayLabel(DateTime(2026, 1, 31)), 'Saturday, 31 Jan');
  });

  test('relativeDayOf names nearby days and marks the others', () {
    final now = DateTime(2026, 9, 11, 23);

    expect(relativeDayOf(DateTime(2026, 9, 11, 1), now), RelativeDay.today);
    expect(
      relativeDayOf(DateTime(2026, 9, 12, 6, 21), now),
      RelativeDay.tomorrow,
    );
    expect(
      relativeDayOf(DateTime(2026, 9, 10, 20), now),
      RelativeDay.yesterday,
    );
    expect(relativeDayOf(DateTime(2026, 9, 8), now), RelativeDay.other);
  });

  test('formatDayRange names the month once when it does not change', () {
    expect(
      formatDayRange(DateTime(2026, 9, 2), DateTime(2026, 9, 8)),
      '2 – 8 Sep',
    );
    expect(
      formatDayRange(DateTime(2026, 8, 28), DateTime(2026, 9, 3)),
      '28 Aug – 3 Sep',
    );
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
