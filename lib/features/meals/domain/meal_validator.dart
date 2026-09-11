/// What is wrong with a meal field. The screen turns it into a message.
enum MealFieldError { nameRequired, nameTooLong, calories }

/// Form rules for a meal.
abstract final class MealValidator {
  static const maxNameLength = 60;
  static const minCalories = 1;
  static const maxCalories = 5000;

  static MealFieldError? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return MealFieldError.nameRequired;
    if (text.length > maxNameLength) return MealFieldError.nameTooLong;
    return null;
  }

  static MealFieldError? calories(String? value) {
    final calories = int.tryParse(value?.trim() ?? '');
    if (calories == null || calories < minCalories || calories > maxCalories) {
      return MealFieldError.calories;
    }
    return null;
  }
}
