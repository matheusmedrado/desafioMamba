import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/dashboard/domain/day_summary.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/history/domain/history_day.dart';
import 'package:mamba_fast_tracker/features/meals/domain/meal.dart';

void main() {
  final now = DateTime(2026, 9, 10, 18);

  Meal meal(int calories, DateTime eatenAt) => Meal(
    id: eatenAt.millisecondsSinceEpoch,
    name: 'Meal',
    calories: calories,
    eatenAt: eatenAt,
  );

  FastingSession fast(DateTime start, DateTime end, {int targetHours = 16}) {
    return FastingSession(
      id: 'fast-${start.millisecondsSinceEpoch}',
      protocolId: '$targetHours:${24 - targetHours}',
      target: Duration(hours: targetHours),
      startedAt: start,
      totalPaused: Duration.zero,
      endedAt: end,
      status: FastingStatus.ended,
    );
  }

  test('groups records by previous local day, newest first', () {
    final history = buildHistory(
      now: now,
      meals: [
        meal(400, DateTime(2026, 9, 8, 12)),
        meal(600, DateTime(2026, 9, 9, 23, 59)),
        meal(900, DateTime(2026, 9, 10, 9)),
      ],
      fasts: [fast(DateTime(2026, 9, 6, 20), DateTime(2026, 9, 7, 12))],
      calorieLimit: 2000,
    );

    expect(history.map((day) => day.day), [
      DateTime(2026, 9, 9),
      DateTime(2026, 9, 8),
      DateTime(2026, 9, 7),
    ]);
    expect(history.first.meals.single.calories, 600);
    expect(history.last.fasts, hasLength(1));
  });

  test('a fast belongs to the day it ended', () {
    final crossed = fast(DateTime(2026, 9, 8, 20), DateTime(2026, 9, 9, 12));

    final history = buildHistory(
      now: now,
      meals: [meal(500, DateTime(2026, 9, 8, 13))],
      fasts: [crossed],
      calorieLimit: 2000,
    );

    final [ninth, eighth] = history;
    expect(ninth.fasts, [crossed]);
    expect(ninth.summary.fastingTime, const Duration(hours: 16));
    expect(eighth.fasts, isEmpty);
    expect(eighth.summary.calories, 500);
  });

  test('each day is judged by its own records and the limit', () {
    final history = buildHistory(
      now: now,
      meals: [
        meal(1800, DateTime(2026, 9, 9, 13)),
        meal(2500, DateTime(2026, 9, 8, 13)),
        meal(1200, DateTime(2026, 9, 7, 13)),
      ],
      fasts: [
        fast(DateTime(2026, 9, 8, 20), DateTime(2026, 9, 9, 12)),
        fast(DateTime(2026, 9, 7, 20), DateTime(2026, 9, 8, 12)),
      ],
      calorieLimit: 2000,
    );

    expect(history.map((day) => day.summary.status), [
      DayGoalStatus.within,
      DayGoalStatus.outside,
      DayGoalStatus.outside,
    ]);
  });

  test('today is not part of history', () {
    final history = buildHistory(
      now: now,
      meals: [meal(300, DateTime(2026, 9, 10))],
      fasts: [fast(DateTime(2026, 9, 9, 20), DateTime(2026, 9, 10, 12))],
      calorieLimit: 2000,
    );

    expect(history, isEmpty);
  });

  test('days are grouped into this week, last week, and earlier', () {
    HistoryGroup groupOf(int daysAgo) =>
        historyGroupOf(DateTime(2026, 9, 10 - daysAgo), now);

    expect(groupOf(1), HistoryGroup.thisWeek);
    expect(groupOf(7), HistoryGroup.thisWeek);
    expect(groupOf(8), HistoryGroup.lastWeek);
    expect(groupOf(14), HistoryGroup.lastWeek);
    expect(groupOf(15), HistoryGroup.earlier);
  });
}
