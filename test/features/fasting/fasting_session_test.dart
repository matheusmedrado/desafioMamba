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

  test('ending before the target freezes elapsed time short of the goal', () {
    final ended = runningSession().endAt(
      startedAt.add(const Duration(hours: 10)),
    );
    final later = startedAt.add(const Duration(days: 2));

    expect(ended.elapsedAt(later), const Duration(hours: 10));
    expect(ended.remainingAt(later), const Duration(hours: 6));
    expect(ended.goalReachedAt(later), isFalse);
    expect(ended.targetEndAt, isNull);
  });

  test('ending after the target keeps the time fasted past the goal', () {
    final ended = runningSession().endAt(
      startedAt.add(const Duration(hours: 17, minutes: 30)),
    );
    final later = startedAt.add(const Duration(days: 2));

    expect(ended.elapsedAt(later), const Duration(hours: 17, minutes: 30));
    expect(ended.remainingAt(later), Duration.zero);
    expect(ended.goalReachedAt(later), isTrue);
  });

  test('several pauses add up and none of them count as fasting', () {
    final session = runningSession()
        .pauseAt(startedAt.add(const Duration(hours: 2)))
        .resumeAt(startedAt.add(const Duration(hours: 3)))
        .pauseAt(startedAt.add(const Duration(hours: 6)))
        .resumeAt(startedAt.add(const Duration(hours: 8)));

    expect(session.totalPaused, const Duration(hours: 3));
    expect(
      session.elapsedAt(startedAt.add(const Duration(hours: 10))),
      const Duration(hours: 7),
    );
    expect(session.targetEndAt, startedAt.add(const Duration(hours: 19)));
  });

  test('a clock set before the start counts no time, not negative time', () {
    final session = runningSession();
    final earlier = startedAt.subtract(const Duration(hours: 1));

    expect(session.elapsedAt(earlier), Duration.zero);
    expect(session.remainingAt(earlier), const Duration(hours: 16));
  });

  test('rejects transitions that do not match the current status', () {
    final running = runningSession();
    final paused = running.pauseAt(startedAt.add(const Duration(hours: 1)));
    final ended = running.endAt(startedAt.add(const Duration(hours: 2)));

    expect(() => running.resumeAt(startedAt), throwsStateError);
    expect(() => paused.pauseAt(startedAt), throwsStateError);
    expect(() => ended.pauseAt(startedAt), throwsStateError);
    expect(() => ended.endAt(startedAt), throwsStateError);
  });

  test('paused and ended sessions survive a JSON round trip', () {
    final paused = runningSession().pauseAt(
      startedAt.add(const Duration(hours: 4)),
    );
    final ended = paused.endAt(startedAt.add(const Duration(hours: 6)));

    expect(FastingSession.fromJson(paused.toJson()), paused);
    expect(FastingSession.fromJson(ended.toJson()), ended);
  });

  test('rejects sessions with missing ids or impossible durations', () {
    FastingSession build({
      String id = 'fast-1',
      String protocolId = '16:8',
      Duration target = const Duration(hours: 16),
      Duration totalPaused = Duration.zero,
    }) => FastingSession(
      id: id,
      protocolId: protocolId,
      target: target,
      startedAt: startedAt,
      totalPaused: totalPaused,
      status: FastingStatus.running,
    );

    expect(() => build(id: ''), throwsArgumentError);
    expect(() => build(protocolId: ''), throwsArgumentError);
    expect(() => build(target: Duration.zero), throwsArgumentError);
    expect(
      () => build(totalPaused: const Duration(minutes: -1)),
      throwsArgumentError,
    );
  });

  test('rejects stored data that breaks the status rules', () {
    final json = runningSession().toJson();

    for (final broken in <Map<String, Object?>>[
      {...json, 'endedAt': 1},
      {...json, 'status': 'paused'},
      {...json, 'status': 'ended'},
      {...json, 'status': 'done'},
      {...json, 'pausedAt': 'noon'},
      {...json, 'targetMilliseconds': 0},
      {...json, 'startedAt': '2026-09-10'},
    ]) {
      expect(() => FastingSession.fromJson(broken), throwsFormatException);
    }
  });
}
