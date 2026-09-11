import '../../../core/local_day.dart';
import '../../dashboard/domain/day_summary.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../meals/domain/meal.dart';

enum HistoryGroup { thisWeek, lastWeek, earlier }

class HistoryDay {
  const HistoryDay({
    required this.day,
    required this.meals,
    required this.fasts,
    required this.summary,
  });

  /// Local midnight that starts the day.
  final DateTime day;
  final List<Meal> meals;
  final List<FastingSession> fasts;
  final DaySummary summary;
}

/// Previous local days with records, newest first.
List<HistoryDay> buildHistory({
  required DateTime now,
  required Iterable<Meal> meals,
  required Iterable<FastingSession> fasts,
  required int calorieLimit,
}) {
  final today = localDayBounds(now).start;

  final mealsByDay = <DateTime, List<Meal>>{};
  for (final meal in meals) {
    final day = localDayBounds(meal.eatenAt).start;
    if (day.isBefore(today)) (mealsByDay[day] ??= []).add(meal);
  }

  final fastsByDay = <DateTime, List<FastingSession>>{};
  for (final fast in fasts) {
    final endedAt = fast.endedAt;
    if (endedAt == null) continue;
    final day = localDayBounds(endedAt).start;
    if (day.isBefore(today)) (fastsByDay[day] ??= []).add(fast);
  }

  final days = {...mealsByDay.keys, ...fastsByDay.keys}.toList()
    ..sort((a, b) => b.compareTo(a));

  return [
    for (final day in days)
      HistoryDay(
        day: day,
        meals: mealsByDay[day] ?? const [],
        fasts: fastsByDay[day] ?? const [],
        summary: DaySummary.calculate(
          day: day,
          now: now,
          meals: mealsByDay[day] ?? const [],
          completedFasts: fastsByDay[day] ?? const [],
          currentFast: null,
          calorieLimit: calorieLimit,
        ),
      ),
  ];
}

HistoryGroup historyGroupOf(DateTime day, DateTime now) {
  final today = localDayBounds(now).start;
  // Rounded because a day with a daylight saving change is 23 or 25 hours.
  final daysAgo = (today.difference(localDayBounds(day).start).inHours / 24)
      .round();
  if (daysAgo <= 7) return HistoryGroup.thisWeek;
  if (daysAgo <= 14) return HistoryGroup.lastWeek;
  return HistoryGroup.earlier;
}
