/// Lifecycle state of a fasting session.
enum FastingStatus { running, paused, ended }

/// Persisted state for one fasting session.
///
/// Elapsed time is always derived from the timestamps and [totalPaused]. The
/// UI may refresh this model periodically, but it never owns an elapsed-time
/// counter.
class FastingSession {
  FastingSession({
    required this.id,
    required this.protocolId,
    required this.target,
    required DateTime startedAt,
    DateTime? pausedAt,
    required this.totalPaused,
    DateTime? endedAt,
    required this.status,
  }) : startedAt = startedAt.toUtc(),
       pausedAt = pausedAt?.toUtc(),
       endedAt = endedAt?.toUtc() {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (protocolId.isEmpty) {
      throw ArgumentError.value(protocolId, 'protocolId', 'must not be empty');
    }
    if (target <= Duration.zero) {
      throw ArgumentError.value(target, 'target', 'must be positive');
    }
    if (totalPaused < Duration.zero) {
      throw ArgumentError.value(
        totalPaused,
        'totalPaused',
        'must not be negative',
      );
    }
  }

  /// Creates a new active session from the selected protocol.
  factory FastingSession.start({
    required String id,
    required String protocolId,
    required Duration target,
    required DateTime startedAt,
  }) {
    return FastingSession(
      id: id,
      protocolId: protocolId,
      target: target,
      startedAt: startedAt,
      totalPaused: Duration.zero,
      status: FastingStatus.running,
    );
  }

  final String id;
  final String protocolId;
  final Duration target;
  final DateTime startedAt;
  final DateTime? pausedAt;
  final Duration totalPaused;
  final DateTime? endedAt;
  final FastingStatus status;

  /// The timestamp at which the target will be reached while running.
  ///
  /// A paused session has no active target time until it is resumed.
  DateTime? get targetEndAt => status == FastingStatus.running
      ? startedAt.add(target + totalPaused)
      : null;

  /// Returns active fasting time at [now], excluding paused periods.
  Duration elapsedAt(DateTime now) {
    final end = switch (status) {
      FastingStatus.running => now.toUtc(),
      FastingStatus.paused => pausedAt ?? now.toUtc(),
      FastingStatus.ended => endedAt ?? now.toUtc(),
    };
    final elapsed = end.difference(startedAt) - totalPaused;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  /// Returns the time left to reach the target at [now].
  Duration remainingAt(DateTime now) {
    final remaining = target - elapsedAt(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether the planned fasting window has been reached at [now].
  bool goalReachedAt(DateTime now) => elapsedAt(now) >= target;

  /// Pauses a running session at [now].
  FastingSession pauseAt(DateTime now) {
    _requireStatus(FastingStatus.running, 'pause');
    return FastingSession(
      id: id,
      protocolId: protocolId,
      target: target,
      startedAt: startedAt,
      pausedAt: now,
      totalPaused: totalPaused,
      status: FastingStatus.paused,
    );
  }

  /// Resumes a paused session at [now].
  FastingSession resumeAt(DateTime now) {
    _requireStatus(FastingStatus.paused, 'resume');
    final pauseStartedAt = pausedAt;
    if (pauseStartedAt == null) {
      throw StateError('Cannot resume a session without pausedAt.');
    }

    return FastingSession(
      id: id,
      protocolId: protocolId,
      target: target,
      startedAt: startedAt,
      totalPaused: totalPaused + _nonNegativeDifference(now, pauseStartedAt),
      status: FastingStatus.running,
    );
  }

  /// Ends a running or paused session at [now].
  ///
  /// Ending while paused includes the pause up to [now] in [totalPaused], so
  /// time spent paused is not counted in the completed fast.
  FastingSession endAt(DateTime now) {
    if (status == FastingStatus.ended) {
      throw StateError('Cannot end an already ended session.');
    }

    final pauseStartedAt = pausedAt;
    final totalPausedAtEnd = pauseStartedAt == null
        ? totalPaused
        : totalPaused + _nonNegativeDifference(now, pauseStartedAt);

    return FastingSession(
      id: id,
      protocolId: protocolId,
      target: target,
      startedAt: startedAt,
      totalPaused: totalPausedAtEnd,
      endedAt: now,
      status: FastingStatus.ended,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'protocolId': protocolId,
    'targetMilliseconds': target.inMilliseconds,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'pausedAt': pausedAt?.millisecondsSinceEpoch,
    'totalPausedMilliseconds': totalPaused.inMilliseconds,
    'endedAt': endedAt?.millisecondsSinceEpoch,
    'status': status.name,
  };

  factory FastingSession.fromJson(Map<String, Object?> json) {
    final id = _requiredString(json, 'id');
    final protocolId = _requiredString(json, 'protocolId');
    final targetMilliseconds = _requiredInt(json, 'targetMilliseconds');
    final totalPausedMilliseconds = _requiredInt(
      json,
      'totalPausedMilliseconds',
    );
    if (targetMilliseconds <= 0) {
      throw const FormatException('targetMilliseconds must be positive');
    }
    if (totalPausedMilliseconds < 0) {
      throw const FormatException(
        'totalPausedMilliseconds must not be negative',
      );
    }

    final statusName = _requiredString(json, 'status');
    final status = _statusFromName(statusName);
    final pausedAt = _optionalTimestamp(json, 'pausedAt');
    final endedAt = _optionalTimestamp(json, 'endedAt');

    switch (status) {
      case FastingStatus.running:
        if (pausedAt != null || endedAt != null) {
          throw const FormatException(
            'running sessions cannot have pausedAt or endedAt',
          );
        }
      case FastingStatus.paused:
        if (pausedAt == null || endedAt != null) {
          throw const FormatException(
            'paused sessions require pausedAt and cannot have endedAt',
          );
        }
      case FastingStatus.ended:
        if (endedAt == null || pausedAt != null) {
          throw const FormatException(
            'ended sessions require endedAt and cannot have pausedAt',
          );
        }
    }

    return FastingSession(
      id: id,
      protocolId: protocolId,
      target: Duration(milliseconds: targetMilliseconds),
      startedAt: _requiredTimestamp(json, 'startedAt'),
      pausedAt: pausedAt,
      totalPaused: Duration(milliseconds: totalPausedMilliseconds),
      endedAt: endedAt,
      status: status,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FastingSession &&
      other.id == id &&
      other.protocolId == protocolId &&
      other.target == target &&
      other.startedAt == startedAt &&
      other.pausedAt == pausedAt &&
      other.totalPaused == totalPaused &&
      other.endedAt == endedAt &&
      other.status == status;

  @override
  int get hashCode => Object.hash(
    id,
    protocolId,
    target,
    startedAt,
    pausedAt,
    totalPaused,
    endedAt,
    status,
  );

  void _requireStatus(FastingStatus expected, String action) {
    if (status != expected) {
      throw StateError('Cannot $action a $status session.');
    }
  }

  static Duration _nonNegativeDifference(DateTime later, DateTime earlier) {
    final difference = later.toUtc().difference(earlier.toUtc());
    return difference.isNegative ? Duration.zero : difference;
  }
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('$key must be a non-empty string');
  }
  return value;
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('$key must be an integer');
  }
  return value;
}

DateTime _requiredTimestamp(Map<String, Object?> json, String key) {
  final milliseconds = _requiredInt(json, key);
  return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
}

DateTime? _optionalTimestamp(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! int) {
    throw FormatException('$key must be an integer or null');
  }
  return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
}

FastingStatus _statusFromName(String name) {
  for (final status in FastingStatus.values) {
    if (status.name == name) return status;
  }
  throw FormatException('Unknown fasting status: $name');
}
