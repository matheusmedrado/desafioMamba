import '../../../core/local_day.dart';
import '../../dashboard/domain/day_summary.dart';
import 'history_day.dart';

class WeekDay {
  const WeekDay({
    required this.day,
    required this.fastCount,
    required this.fastingTime,
    required this.fastingGoalReached,
    required this.withinGoal,
  });

  /// Local midnight that starts the day.
  final DateTime day;
  final int fastCount;
  final Duration fastingTime;
  final bool fastingGoalReached;
  final bool withinGoal;

  bool get hasFast => fastCount > 0;
}

class WeekSummary {
  const WeekSummary({
    required this.days,
    required this.daysWithinGoal,
    required this.averageFast,
    required this.bestDay,
  });

  factory WeekSummary.fromHistory(List<HistoryDay> history, DateTime now) {
    final today = localDayBounds(now).start;
    final byDay = {for (final entry in history) entry.day: entry};

    final days = [
      for (var daysAgo = 7; daysAgo >= 1; daysAgo--)
        _weekDay(DateTime(today.year, today.month, today.day - daysAgo), byDay),
    ];

    final fastCount = days.fold(0, (total, day) => total + day.fastCount);
    final totalFasting = days.fold(
      Duration.zero,
      (total, day) => total + day.fastingTime,
    );
    final fasted = days.where((day) => day.hasFast);

    return WeekSummary(
      days: days,
      daysWithinGoal: days.where((day) => day.withinGoal).length,
      averageFast: fastCount == 0 ? null : totalFasting ~/ fastCount,
      bestDay: fasted.isEmpty
          ? null
          : fasted.reduce(
              (best, day) => day.fastingTime > best.fastingTime ? day : best,
            ),
    );
  }

  /// The seven days before today, oldest first.
  final List<WeekDay> days;
  final int daysWithinGoal;
  final Duration? averageFast;
  final WeekDay? bestDay;

  static WeekDay _weekDay(DateTime day, Map<DateTime, HistoryDay> byDay) {
    final entry = byDay[day];
    return WeekDay(
      day: day,
      fastCount: entry?.fasts.length ?? 0,
      fastingTime: entry?.summary.fastingTime ?? Duration.zero,
      fastingGoalReached: entry?.summary.fastingGoalReached ?? false,
      withinGoal: entry?.summary.status == DayGoalStatus.within,
    );
  }
}
