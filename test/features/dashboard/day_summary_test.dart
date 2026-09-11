import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/dashboard/domain/day_summary.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';
import 'package:mamba_fast_tracker/features/meals/domain/meal.dart';

void main() {
  const limit = 2000;
  final today = DateTime(2026, 9, 10);
  final yesterday = DateTime(2026, 9, 9);

  Meal meal(int calories, DateTime eatenAt) => Meal(
    id: eatenAt.millisecondsSinceEpoch,
    name: 'Meal',
    calories: calories,
    eatenAt: eatenAt,
  );

  FastingSession endedFast(
    DateTime start,
    DateTime end, {
    int targetHours = 16,
    Duration paused = Duration.zero,
  }) {
    return FastingSession(
      id: 'fast-${start.millisecondsSinceEpoch}',
      protocolId: '$targetHours:${24 - targetHours}',
      target: Duration(hours: targetHours),
      startedAt: start,
      totalPaused: paused,
      endedAt: end,
      status: FastingStatus.ended,
    );
  }

  FastingSession runningFast(DateTime start) => FastingSession.start(
    id: 'fast-${start.millisecondsSinceEpoch}',
    protocolId: '16:8',
    target: const Duration(hours: 16),
    startedAt: start,
  );

  DaySummary summarize({
    DateTime? day,
    required DateTime now,
    List<Meal> meals = const [],
    List<FastingSession> completed = const [],
    FastingSession? current,
  }) {
    return DaySummary.calculate(
      day: day ?? today,
      now: now,
      meals: meals,
      completedFasts: completed,
      currentFast: current,
      calorieLimit: limit,
    );
  }

  group('calories', () {
    test('counts only meals eaten on the local day', () {
      final summary = summarize(
        now: DateTime(2026, 9, 10, 21),
        meals: [
          meal(300, DateTime(2026, 9, 9, 23, 59)),
          meal(500, DateTime(2026, 9, 10)),
          meal(700, DateTime(2026, 9, 10, 23, 59)),
          meal(900, DateTime(2026, 9, 11)),
        ],
      );

      expect(summary.calories, 1200);
    });

    test('the limit itself is within and one calorie more is outside', () {
      final reached = endedFast(
        DateTime(2026, 9, 9, 20),
        DateTime(2026, 9, 10, 12),
      );
      DaySummary withCalories(int calories) => summarize(
        now: DateTime(2026, 9, 10, 21),
        meals: [meal(calories, DateTime(2026, 9, 10, 13))],
        completed: [reached],
      );

      final atLimit = withCalories(2000);
      expect(atLimit.caloriesWithinLimit, isTrue);
      expect(atLimit.status, DayGoalStatus.within);

      final over = withCalories(2001);
      expect(over.caloriesWithinLimit, isFalse);
      expect(over.status, DayGoalStatus.outside);
    });
  });

  group('fasting time', () {
    test('a fast counts on the day it ends, not the day it starts', () {
      final fast = endedFast(
        DateTime(2026, 9, 9, 20),
        DateTime(2026, 9, 10, 12),
      );
      final now = DateTime(2026, 9, 10, 18);

      final startDay = summarize(day: yesterday, now: now, completed: [fast]);
      expect(startDay.fastingTime, Duration.zero);
      expect(startDay.fastingGoalReached, isFalse);

      final endDay = summarize(now: now, completed: [fast]);
      expect(endDay.fastingTime, const Duration(hours: 16));
      expect(endDay.fastingGoalReached, isTrue);
    });

    test('adds every fast that ended on the day without paused time', () {
      final summary = summarize(
        now: DateTime(2026, 9, 10, 22),
        completed: [
          endedFast(DateTime(2026, 9, 10), DateTime(2026, 9, 10, 6)),
          endedFast(
            DateTime(2026, 9, 10, 8),
            DateTime(2026, 9, 10, 20),
            paused: const Duration(hours: 2),
          ),
        ],
      );

      expect(summary.fastingTime, const Duration(hours: 16));
      expect(summary.fastingGoalReached, isFalse);
    });

    test('each fast is compared with its own target', () {
      DaySummary withTarget(int hours) => summarize(
        now: DateTime(2026, 9, 10, 22),
        completed: [
          endedFast(
            DateTime(2026, 9, 10),
            DateTime(2026, 9, 10, 13),
            targetHours: hours,
          ),
        ],
      );

      expect(withTarget(12).fastingGoalReached, isTrue);
      expect(withTarget(18).fastingGoalReached, isFalse);
    });

    test('the running fast counts toward today up to now', () {
      final running = runningFast(DateTime(2026, 9, 10, 2));
      final now = DateTime(2026, 9, 10, 10);

      expect(
        summarize(now: now, current: running).fastingTime,
        const Duration(hours: 8),
      );
      expect(
        summarize(day: yesterday, now: now, current: running).fastingTime,
        Duration.zero,
      );
    });

    test('a paused fast counts its time without the pause', () {
      final paused = runningFast(DateTime(2026, 9, 10, 2))
          .pauseAt(DateTime(2026, 9, 10, 6));

      expect(
        summarize(now: DateTime(2026, 9, 10, 10), current: paused).fastingTime,
        const Duration(hours: 4),
      );
    });

    test('an ended fast is counted once whether or not it was copied', () {
      final fast = endedFast(
        DateTime(2026, 9, 9, 20),
        DateTime(2026, 9, 10, 12),
      );
      final now = DateTime(2026, 9, 10, 18);

      expect(
        summarize(now: now, completed: [fast], current: fast).fastingTime,
        const Duration(hours: 16),
      );
      expect(
        summarize(now: now, current: fast).fastingTime,
        const Duration(hours: 16),
      );
    });
  });

  group('goal status', () {
    test('today is in progress before any fast ends', () {
      expect(
        summarize(now: DateTime(2026, 9, 10, 9)).status,
        DayGoalStatus.inProgress,
      );
      expect(
        summarize(
          now: DateTime(2026, 9, 10, 9),
          current: runningFast(DateTime(2026, 9, 10, 1)),
        ).status,
        DayGoalStatus.inProgress,
      );
    });

    test('today is within once a fast reaches its target, even running', () {
      final running = runningFast(DateTime(2026, 9, 9, 17));

      expect(
        summarize(now: DateTime(2026, 9, 10, 9, 30), current: running).status,
        DayGoalStatus.within,
      );
    });

    test('today is outside after a fast ends short and none is open', () {
      final short = endedFast(DateTime(2026, 9, 10), DateTime(2026, 9, 10, 5));
      final now = DateTime(2026, 9, 10, 12);

      expect(
        summarize(now: now, completed: [short]).status,
        DayGoalStatus.outside,
      );
      expect(
        summarize(
          now: now,
          completed: [short],
          current: runningFast(DateTime(2026, 9, 10, 6)),
        ).status,
        DayGoalStatus.inProgress,
      );
    });

    test('today is outside as soon as calories go over the limit', () {
      final summary = summarize(
        now: DateTime(2026, 9, 10, 10),
        meals: [meal(2500, DateTime(2026, 9, 10, 9))],
        current: runningFast(DateTime(2026, 9, 10, 2)),
      );

      expect(summary.status, DayGoalStatus.outside);
    });

    test('a past day without a reached fast is outside', () {
      expect(
        summarize(day: yesterday, now: DateTime(2026, 9, 10, 9)).status,
        DayGoalStatus.outside,
      );
    });
  });
}
