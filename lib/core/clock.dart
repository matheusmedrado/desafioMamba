import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of the current time for all time based logic.
///
/// Fasting calculations must derive elapsed and remaining time from persisted
/// timestamps plus this clock, never from an in-memory counter. Injecting the
/// clock keeps those calculations testable with fixed dates.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Fixed clock for tests. Advance it explicitly to simulate time passing.
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  void set(DateTime value) {
    _now = value;
  }
}

final clockProvider = Provider<Clock>((ref) => const SystemClock());
