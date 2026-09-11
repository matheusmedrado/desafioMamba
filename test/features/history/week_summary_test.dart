import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/history/domain/history_day.dart';
import 'package:mamba_fast_tracker/features/history/domain/week_summary.dart';
import 'package:mamba_fast_tracker/features/meals/domain/meal.dart';

void main() {
  final now = DateTime(2026, 9, 10, 18);

  Meal meal(int calories, DateTime eatenAt) => Meal(
    id: eatenAt.millisecondsSinceEpoch,
    name: 'Meal',
    calories: calories,
    eatenAt: eatenAt,
  );

  FastingSession fast(DateTime start, DateTime end) {
    return FastingSession(
      id: 'fast-${start.millisecondsSinceEpoch}',
      protocolId: '16:8',
      target: const Duration(hours: 16),
      startedAt: start,
      totalPaused: Duration.zero,
      endedAt: end,
      status: FastingStatus.ended,
    );
  }

  WeekSummary summarize({
    List<Meal> meals = const [],
    List<FastingSession> fasts = const [],
  }) {
    final history = buildHistory(
      now: now,
      meals: meals,
      fasts: fasts,
      calorieLimit: 2000,
    );
    return WeekSummary.fromHistory(history, now);
  }

  test('covers the seven days before today, oldest first', () {
    final week = summarize();

    expect(week.days.map((day) => day.day), [
      for (var day = 3; day <= 9; day++) DateTime(2026, 9, day),
    ]);
    expect(week.days.every((day) => !day.hasFast), isTrue);
    expect(week.daysWithinGoal, 0);
    expect(week.averageFast, isNull);
    expect(week.bestDay, isNull);
  });

  test('uses the full day goal for the count and each fast for the bar', () {
    final week = summarize(
      meals: [
        meal(1800, DateTime(2026, 9, 9, 13)),
        meal(2500, DateTime(2026, 9, 8, 13)),
      ],
      fasts: [
        fast(DateTime(2026, 9, 8, 20), DateTime(2026, 9, 9, 12, 30)),
        fast(DateTime(2026, 9, 7, 20), DateTime(2026, 9, 8, 13)),
        fast(DateTime(2026, 9, 6, 20), DateTime(2026, 9, 7, 4)),
        fast(DateTime(2026, 9, 1, 20), DateTime(2026, 9, 2, 13)),
      ],
    );

    final [..., seventh, eighth, ninth] = week.days;
    expect(ninth.withinGoal, isTrue);
    expect(eighth.fastingGoalReached, isTrue);
    expect(eighth.withinGoal, isFalse);
    expect(seventh.hasFast, isTrue);
    expect(seventh.fastingGoalReached, isFalse);
    expect(week.daysWithinGoal, 1);
  });

  test('averages per fast and picks the longest day', () {
    final week = summarize(
      fasts: [
        fast(DateTime(2026, 9, 8, 20), DateTime(2026, 9, 9, 12, 30)),
        fast(DateTime(2026, 9, 7, 20), DateTime(2026, 9, 8, 13)),
        fast(DateTime(2026, 9, 6, 20), DateTime(2026, 9, 7, 4)),
      ],
    );

    expect(week.averageFast, const Duration(hours: 13, minutes: 50));
    expect(week.bestDay?.day, DateTime(2026, 9, 8));
    expect(week.bestDay?.fastingTime, const Duration(hours: 17));
  });
}
