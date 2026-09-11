import '../../../core/local_day.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../meals/domain/meal.dart';

enum DayGoalStatus { within, outside, inProgress }

/// Calorie and fasting totals for one local calendar day, with its goal
/// status.
///
/// Goal rule: a day is within goal when its calories are at or under the
/// calorie limit and a fast credited to that day reached its own target. A
/// fast is credited to the local day it ends. A fast that has not ended is
/// credited to today.
///
/// Today stays in progress while the goal can still be reached: calories are
/// within the limit, and either a fast is still open or no fast has ended yet.
class DaySummary {
  const DaySummary({
    required this.calories,
    required this.calorieLimit,
    required this.fastingTime,
    required this.fastingGoalReached,
    required this.status,
  });

  factory DaySummary.calculate({
    required DateTime day,
    required DateTime now,
    required Iterable<Meal> meals,
    required Iterable<FastingSession> completedFasts,
    required FastingSession? currentFast,
    required int calorieLimit,
  }) {
    final isToday = isOnLocalDay(now, day);
    final calories = totalCalories(
      meals.where((meal) => isOnLocalDay(meal.eatenAt, day)),
    );

    // The current fast can be an ended fast that is also in completed storage,
    // or one that has not been copied there yet. Keying by id counts it once.
    final credited = <String, FastingSession>{
      for (final fast in completedFasts)
        if (_endedOn(fast, day)) fast.id: fast,
    };
    final current = currentFast;
    if (current != null) {
      final creditedToDay = current.status == FastingStatus.ended
          ? _endedOn(current, day)
          : isToday;
      if (creditedToDay) credited[current.id] = current;
    }

    final fasts = credited.values;
    final fastingTime = fasts.fold(
      Duration.zero,
      (total, fast) => total + fast.elapsedAt(now),
    );
    final goalReached = fasts.any((fast) => fast.goalReachedAt(now));
    final fastStillOpen = fasts.any(
      (fast) => fast.status != FastingStatus.ended,
    );
    final anyEnded = fasts.any((fast) => fast.status == FastingStatus.ended);

    return DaySummary(
      calories: calories,
      calorieLimit: calorieLimit,
      fastingTime: fastingTime,
      fastingGoalReached: goalReached,
      status: _status(
        withinLimit: calories <= calorieLimit,
        goalReached: goalReached,
        canStillReachGoal: isToday && (fastStillOpen || !anyEnded),
      ),
    );
  }

  final int calories;
  final int calorieLimit;
  final Duration fastingTime;
  final bool fastingGoalReached;
  final DayGoalStatus status;

  bool get caloriesWithinLimit => calories <= calorieLimit;

  static DayGoalStatus _status({
    required bool withinLimit,
    required bool goalReached,
    required bool canStillReachGoal,
  }) {
    if (!withinLimit) return DayGoalStatus.outside;
    if (goalReached) return DayGoalStatus.within;
    if (canStillReachGoal) return DayGoalStatus.inProgress;
    return DayGoalStatus.outside;
  }

  static bool _endedOn(FastingSession fast, DateTime day) {
    final endedAt = fast.endedAt;
    return endedAt != null && isOnLocalDay(endedAt, day);
  }
}
