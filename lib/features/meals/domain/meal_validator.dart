/// Form rules for a meal. Returns an error message or null.
abstract final class MealValidator {
  static const maxNameLength = 60;
  static const minCalories = 1;
  static const maxCalories = 5000;

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Give the meal a name.';
    if (text.length > maxNameLength) {
      return 'Use at most $maxNameLength characters.';
    }
    return null;
  }

  static String? calories(String? value) {
    final calories = int.tryParse(value?.trim() ?? '');
    if (calories == null || calories < minCalories || calories > maxCalories) {
      return 'Enter a whole number between 1 and 5,000.';
    }
    return null;
  }
}
