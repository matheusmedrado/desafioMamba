import 'package:intl/intl.dart';

import 'local_day.dart';

/// Part of the day for the greeting. The screen turns it into a message.
enum Greeting { morning, afternoon, evening }

Greeting greetingAt(DateTime time) {
  final hour = time.toLocal().hour;
  if (hour < 12) return Greeting.morning;
  if (hour < 18) return Greeting.afternoon;
  return Greeting.evening;
}

/// A day named after [now]. Other days are shown with their date.
enum RelativeDay { today, tomorrow, yesterday, other }

RelativeDay relativeDayOf(DateTime time, DateTime now) {
  final today = localDayBounds(now).start;
  // Rounded because a day with a daylight saving change is 23 or 25 hours.
  final days = (localDayBounds(time).start.difference(today).inHours / 24)
      .round();
  return switch (days) {
    0 => RelativeDay.today,
    1 => RelativeDay.tomorrow,
    -1 => RelativeDay.yesterday,
    _ => RelativeDay.other,
  };
}

/// Formats the local calendar day, such as "Wednesday, 9 Sep".
String formatDayLabel(DateTime time) =>
    DateFormat('EEEE, d MMM').format(time.toLocal());

/// Formats two local days as a range, such as "2 – 8 Sep".
String formatDayRange(DateTime start, DateTime end) {
  final first = start.toLocal();
  final last = end.toLocal();
  final lastLabel = DateFormat('d MMM').format(last);
  return first.month == last.month && first.year == last.year
      ? '${first.day} – $lastLabel'
      : '${DateFormat('d MMM').format(first)} – $lastLabel';
}

/// Short local weekday, such as "Wed".
String formatWeekdayShort(DateTime time) =>
    DateFormat('EEE').format(time.toLocal());

/// Formats the local time of day on a 24-hour clock, such as "16:20".
String formatClockTime(DateTime time) =>
    DateFormat('HH:mm').format(time.toLocal());

/// Formats a duration as whole hours and minutes, such as "5h 41m".
String formatHoursMinutes(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '${duration.inHours}h ${minutes}m';
}

/// Formats a whole number for the current language, such as "1,240".
String formatThousands(int value) =>
    NumberFormat.decimalPattern().format(value);
