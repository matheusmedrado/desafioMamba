import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';

void main() {
  final startedAt = DateTime.utc(2026, 9, 10, 8);

  FastingSession runningSession() {
    return FastingSession.start(
      id: 'fast-1',
      protocolId: '16:8',
      target: const Duration(hours: 16),
      startedAt: startedAt,
    );
  }

  test('derives elapsed, remaining, and target completion while running', () {
    final session = runningSession();
    final now = startedAt.add(const Duration(hours: 5, minutes: 12));

    expect(session.elapsedAt(now), const Duration(hours: 5, minutes: 12));
    expect(session.remainingAt(now), const Duration(hours: 10, minutes: 48));
    expect(session.goalReachedAt(now), isFalse);
    expect(session.targetEndAt, startedAt.add(const Duration(hours: 16)));
  });

  test('elapsed time stays frozen while paused', () {
    final session = runningSession();
    final paused = session.pauseAt(startedAt.add(const Duration(hours: 5)));

    expect(
      paused.elapsedAt(startedAt.add(const Duration(hours: 12))),
      const Duration(hours: 5),
    );
    expect(
      paused.remainingAt(startedAt.add(const Duration(hours: 12))),
      const Duration(hours: 11),
    );
    expect(paused.targetEndAt, isNull);
  });

  test('resume adds the paused interval and moves the target end', () {
    final paused = runningSession().pauseAt(
      startedAt.add(const Duration(hours: 5)),
    );
    final resumed = paused.resumeAt(startedAt.add(const Duration(hours: 7)));

    expect(resumed.status, FastingStatus.running);
    expect(resumed.pausedAt, isNull);
    expect(resumed.totalPaused, const Duration(hours: 2));
    expect(
      resumed.elapsedAt(startedAt.add(const Duration(hours: 8))),
      const Duration(hours: 6),
    );
    expect(resumed.targetEndAt, startedAt.add(const Duration(hours: 18)));
  });

  test('ending while paused excludes the pause from elapsed time', () {
    final paused = runningSession().pauseAt(
      startedAt.add(const Duration(hours: 3)),
    );
    final ended = paused.endAt(startedAt.add(const Duration(hours: 8)));

    expect(ended.status, FastingStatus.ended);
    expect(ended.pausedAt, isNull);
    expect(ended.endedAt, startedAt.add(const Duration(hours: 8)));
    expect(ended.totalPaused, const Duration(hours: 5));
    expect(
      ended.elapsedAt(startedAt.add(const Duration(hours: 20))),
      const Duration(hours: 3),
    );
  });

  test('reaching the target keeps the session running', () {
    final session = runningSession();

    expect(
      session.goalReachedAt(startedAt.add(const Duration(hours: 17))),
      isTrue,
    );
    expect(session.status, FastingStatus.running);
    expect(session.endedAt, isNull);
    expect(
      session.remainingAt(startedAt.add(const Duration(hours: 17))),
      Duration.zero,
    );
  });

  test('persists a session as a UTC timestamp round trip', () {
    final session = runningSession();

    expect(FastingSession.fromJson(session.toJson()), session);
    expect(session.startedAt.isUtc, isTrue);
  });
}
