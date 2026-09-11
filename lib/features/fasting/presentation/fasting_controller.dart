import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../data/fasting_repository.dart';
import '../data/fasting_notification_service.dart';
import '../domain/fasting_session.dart';
import 'protocol_controller.dart';

/// Owns the current fasting session and refreshes its display state.
///
/// The ticker only causes the UI to rebuild. The session timestamps in the
/// repository remain the source of truth for all time calculations.
class FastingController extends AsyncNotifier<FastingSession?> {
  Timer? _ticker;

  @override
  Future<FastingSession?> build() async {
    ref.onDispose(_stopTicker);
    final session = await ref.watch(fastingRepositoryProvider).load();
    await _syncNotifications(session);
    _syncTicker(session);
    return session;
  }

  /// Notifies listeners for every new state, even when the session is equal.
  ///
  /// Elapsed time is read from the clock when the screen rebuilds. The ticker
  /// and [restore] emit an unchanged session, so equality filtering would
  /// freeze the displayed time.
  @override
  bool updateShouldNotify(
    AsyncValue<FastingSession?> previous,
    AsyncValue<FastingSession?> next,
  ) => !identical(previous, next);

  Future<void> start() async {
    final settings = await ref.read(protocolControllerProvider.future);
    final protocol = settings.selected;
    final now = ref.read(clockProvider).now().toUtc();
    final session = FastingSession.start(
      id: 'fast-${now.microsecondsSinceEpoch}',
      protocolId: protocol.id,
      target: protocol.target,
      startedAt: now,
    );
    await _save(session, showStartedNotification: true);
  }

  Future<void> pause() {
    return _transition((session, now) => session.pauseAt(now));
  }

  Future<void> resume() {
    return _transition((session, now) => session.resumeAt(now));
  }

  Future<void> end() {
    return _transition((session, now) => session.endAt(now));
  }

  /// Reloads the durable session and restarts the display ticker if needed.
  ///
  /// This is called after the app returns to the foreground. It also makes a
  /// cold-start restoration explicit for callers that own app lifecycle.
  Future<void> restore() async {
    try {
      final session = await ref.read(fastingRepositoryProvider).load();
      await _syncNotifications(session);
      state = AsyncData(session);
      _syncTicker(session);
    } catch (error, stackTrace) {
      _stopTicker();
      state = AsyncError(error, stackTrace);
    }
  }

  /// Stops display refresh while the app is not visible.
  void pauseTicker() {
    _stopTicker();
  }

  /// Rebuilds consumers using the current clock without changing persistence.
  void refreshDisplay() {
    final session = state.value;
    if (session == null || session.status != FastingStatus.running) {
      _stopTicker();
      return;
    }
    state = AsyncData(session);
  }

  Future<void> _transition(
    FastingSession Function(FastingSession session, DateTime now) transition,
  ) async {
    final session = state.value;
    if (session == null) {
      throw StateError('There is no fasting session to update.');
    }
    final updated = transition(session, ref.read(clockProvider).now());
    await _save(updated);
  }

  Future<void> _save(
    FastingSession session, {
    bool showStartedNotification = false,
  }) async {
    // Persist before exposing the new state so a restart cannot observe a
    // transition that was only applied in memory.
    await ref.read(fastingRepositoryProvider).save(session);
    if (showStartedNotification) {
      await _notify((notifications) => notifications.showFastStarted());
    }
    await _syncNotifications(session);
    state = AsyncData(session);
    _syncTicker(session);
  }

  Future<void> _syncNotifications(FastingSession? session) {
    final now = ref.read(clockProvider).now();
    return _notify((notifications) => notifications.sync(session, now));
  }

  /// Runs a notification call without letting its failure reach the timer.
  ///
  /// Notifications are a reminder projected from the saved session. If the
  /// platform rejects a call, the fast must still load and change state. The
  /// next transition or restore synchronizes again.
  Future<void> _notify(
    Future<void> Function(FastingNotificationService notifications) call,
  ) async {
    try {
      await call(ref.read(fastingNotificationServiceProvider));
    } catch (error, stackTrace) {
      developer.log(
        'Fasting notification failed',
        name: 'fasting.notifications',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _syncTicker(FastingSession? session) {
    if (session?.status != FastingStatus.running) {
      _stopTicker();
      return;
    }
    if (_ticker != null) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      refreshDisplay();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

/// Auto-disposed so the ticker stops when no screen shows the timer, such as
/// after logout. The next build reloads the session from storage.
final fastingControllerProvider =
    AsyncNotifierProvider.autoDispose<FastingController, FastingSession?>(
      FastingController.new,
    );
