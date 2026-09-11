import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/local_day.dart';

void main() {
  test('a day runs from local midnight to the next local midnight', () {
    final bounds = localDayBounds(DateTime(2026, 9, 10, 15, 30));

    expect(bounds.start, DateTime(2026, 9, 10));
    expect(bounds.end, DateTime(2026, 9, 11));
  });

  test('the next day starts correctly across a year end', () {
    expect(localDayBounds(DateTime(2026, 12, 31, 20)).end, DateTime(2027));
  });

  test('includes the first instant and excludes the next midnight', () {
    final day = DateTime(2026, 9, 10, 12);

    expect(isOnLocalDay(DateTime(2026, 9, 10), day), isTrue);
    expect(isOnLocalDay(DateTime(2026, 9, 10, 23, 59, 59), day), isTrue);
    expect(isOnLocalDay(DateTime(2026, 9, 11), day), isFalse);
    expect(isOnLocalDay(DateTime(2026, 9, 9, 23, 59, 59), day), isFalse);
  });

  test('a UTC timestamp belongs to the local day of the same instant', () {
    final local = DateTime(2026, 9, 10, 8);

    expect(isOnLocalDay(local.toUtc(), DateTime(2026, 9, 10)), isTrue);
  });
}
