import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/meals/domain/meal_validator.dart';

void main() {
  group('name', () {
    test('rejects empty input', () {
      for (final value in ['', '   ', null]) {
        expect(MealValidator.name(value), MealFieldError.nameRequired);
      }
    });

    test('limits the trimmed length', () {
      expect(MealValidator.name('a' * 60), isNull);
      expect(MealValidator.name(' ${'a' * 60} '), isNull);
      expect(MealValidator.name('a' * 61), MealFieldError.nameTooLong);
    });
  });

  group('calories', () {
    test('accepts whole numbers from 1 to 5000', () {
      expect(MealValidator.calories('1'), isNull);
      expect(MealValidator.calories(' 450 '), isNull);
      expect(MealValidator.calories('5000'), isNull);
    });

    test('rejects empty, out of range, and non-integer input', () {
      for (final value in [null, '', '0', '-5', '5001', '12.5', 'abc']) {
        expect(
          MealValidator.calories(value),
          MealFieldError.calories,
          reason: 'value: $value',
        );
      }
    });
  });
}
