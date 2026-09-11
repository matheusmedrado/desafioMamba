/// Rules for the daily calorie limit.
abstract final class CalorieLimit {
  static const defaultValue = 2000;
  static const min = 500;
  static const max = 5000;

  static bool isValid(int value) => value >= min && value <= max;

  /// Form rule. Returns an error message or null.
  static String? validate(String? value) {
    final limit = int.tryParse(value?.trim() ?? '');
    if (limit == null || !isValid(limit)) {
      return 'Enter a whole number between 500 and 5,000.';
    }
    return null;
  }
}
