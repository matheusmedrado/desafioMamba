/// The local calendar day that contains [time], as a half-open range: [start]
/// is included and [end] is not.
///
/// Both ends are built from calendar fields, so a day with a daylight saving
/// change still ends at the next local midnight.
({DateTime start, DateTime end}) localDayBounds(DateTime time) {
  final local = time.toLocal();
  return (
    start: DateTime(local.year, local.month, local.day),
    end: DateTime(local.year, local.month, local.day + 1),
  );
}

/// Whether the instant [time] falls on the local calendar day that contains
/// [day].
bool isOnLocalDay(DateTime time, DateTime day) {
  final bounds = localDayBounds(day);
  return !time.isBefore(bounds.start) && time.isBefore(bounds.end);
}
