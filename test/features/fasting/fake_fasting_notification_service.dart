import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';

class RecordedNotificationSync {
  RecordedNotificationSync(this.session, this.now);

  final FastingSession? session;
  final DateTime now;
}

class RecordingFastingNotificationService
    implements FastingNotificationService {
  var startedCount = 0;
  var cancelAllCount = 0;
  final syncCalls = <RecordedNotificationSync>[];

  @override
  Future<void> showFastStarted() async {
    startedCount++;
  }

  @override
  Future<void> sync(FastingSession? session, DateTime now) async {
    syncCalls.add(RecordedNotificationSync(session, now));
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
  }
}

/// Simulates a device where the notification plugin cannot be used.
class FailingFastingNotificationService implements FastingNotificationService {
  @override
  Future<void> showFastStarted() async {
    throw StateError('Notifications are unavailable.');
  }

  @override
  Future<void> sync(FastingSession? session, DateTime now) async {
    throw StateError('Notifications are unavailable.');
  }

  @override
  Future<void> cancelAll() async {
    throw StateError('Notifications are unavailable.');
  }
}
