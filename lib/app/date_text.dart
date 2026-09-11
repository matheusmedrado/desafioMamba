import '../core/formatting.dart';
import '../l10n/app_localizations.dart';

/// Names a day near today, and falls back to its date.
String relativeDayText(AppLocalizations l10n, DateTime time, DateTime now) {
  return switch (relativeDayOf(time, now)) {
    RelativeDay.today => l10n.today,
    RelativeDay.tomorrow => l10n.tomorrow,
    RelativeDay.yesterday => l10n.yesterday,
    RelativeDay.other => formatDayLabel(time),
  };
}

String greetingText(AppLocalizations l10n, DateTime now) {
  return switch (greetingAt(now)) {
    Greeting.morning => l10n.greetingMorning,
    Greeting.afternoon => l10n.greetingAfternoon,
    Greeting.evening => l10n.greetingEvening,
  };
}
