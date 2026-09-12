/// Rules for the daily calorie limit.
abstract final class CalorieLimit {
  static const defaultValue = 2000;
  static const min = 500;
  static const max = 5000;

  static bool isValid(int value) => value >= min && value <= max;

  /// Form rule for typed input. The screen writes the error message.
  static bool isValidText(String? value) {
    final limit = int.tryParse(value?.trim() ?? '');
    return limit != null && isValid(limit);
  }
}
