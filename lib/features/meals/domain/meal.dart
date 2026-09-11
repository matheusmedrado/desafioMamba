/// One logged meal.
///
/// [eatenAt] is recorded when the meal is added and stays the same when the
/// name or calories are edited.
class Meal {
  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required DateTime eatenAt,
  }) : eatenAt = eatenAt.toUtc();

  final int id;
  final String name;
  final int calories;
  final DateTime eatenAt;

  Meal copyWith({String? name, int? calories}) {
    return Meal(
      id: id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      eatenAt: eatenAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Meal &&
      other.id == id &&
      other.name == name &&
      other.calories == calories &&
      other.eatenAt == eatenAt;

  @override
  int get hashCode => Object.hash(id, name, calories, eatenAt);
}

int totalCalories(Iterable<Meal> meals) {
  return meals.fold(0, (total, meal) => total + meal.calories);
}
