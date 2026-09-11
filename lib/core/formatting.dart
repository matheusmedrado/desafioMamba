const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats the local calendar day, such as "Wednesday, 9 Sep".
String formatDayLabel(DateTime time) {
  final local = time.toLocal();
  return '${_weekdays[local.weekday - 1]}, ${local.day} '
      '${_months[local.month - 1]}';
}

/// Short local weekday, such as "Wed".
String formatWeekdayShort(DateTime time) =>
    _weekdays[time.toLocal().weekday - 1].substring(0, 3);

/// Formats the local time of day on a 24-hour clock, such as "16:20".
String formatClockTime(DateTime time) {
  final local = time.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

/// Formats a duration as whole hours and minutes, such as "5h 41m".
String formatHoursMinutes(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '${duration.inHours}h ${minutes}m';
}

/// Formats a non-negative whole number with thousands separators, such as
/// "1,240".
String formatThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
