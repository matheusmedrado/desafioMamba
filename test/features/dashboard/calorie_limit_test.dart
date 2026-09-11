import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/dashboard/domain/calorie_limit.dart';

void main() {
  test('the default is a valid limit', () {
    expect(CalorieLimit.isValid(CalorieLimit.defaultValue), isTrue);
  });

  test('accepts whole numbers from 500 to 5000', () {
    for (final value in ['500', ' 2000 ', '5000']) {
      expect(CalorieLimit.validate(value), isNull, reason: 'value: $value');
    }
  });

  test('rejects empty, out of range, and non-integer input', () {
    for (final value in [null, '', '499', '5001', '1500.5', 'abc']) {
      expect(
        CalorieLimit.validate(value),
        'Enter a whole number between 500 and 5,000.',
        reason: 'value: $value',
      );
    }
  });
}
