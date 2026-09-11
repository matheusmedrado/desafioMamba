import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/formatting.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/fasting_session.dart';

/// Notification text follows the device language, since there is no screen.
AppLocalizations _messages() {
  final language = PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.any(
    (locale) => locale.languageCode == language,
  );
  return lookupAppLocalizations(Locale(supported ? language : 'en'));
}

/// Notification operations needed by the fasting controller.
abstract class FastingNotificationService {
  Future<void> showFastStarted();

  Future<void> sync(FastingSession? session, DateTime now);

  /// Removes every fasting notification, such as when the user logs out.
  Future<void> cancelAll();
}

/// Local notification implementation for Android.
class LocalFastingNotificationService implements FastingNotificationService {
  LocalFastingNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _startNotificationId = 1001;
  static const _goalNotificationId = 1002;
  static const _progressNotificationId = 1003;
  static const _channelId = 'fasting_updates';
  static const _channelName = 'Fasting updates';
  static const _channelDescription =
      'Notifications about the current fasting session.';
  static const _progressChannelId = 'fasting_progress';
  static const _progressChannelName = 'Fasting in progress';
  static const _progressChannelDescription =
      'Shows the time of the fast that is running.';
  static const _androidNotificationDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    importance: Importance.high,
    priority: Priority.high,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  @override
  Future<void> showFastStarted() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _ensureInitialized();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final l10n = _messages();
    await _plugin.show(
      id: _startNotificationId,
      title: l10n.notificationStartedTitle,
      body: l10n.notificationStartedBody,
      notificationDetails: const NotificationDetails(
        android: _androidNotificationDetails,
      ),
    );
  }

  @override
  Future<void> sync(FastingSession? session, DateTime now) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _ensureInitialized();
    await _plugin.cancel(id: _goalNotificationId);

    if (session == null || session.status == FastingStatus.ended) {
      await _plugin.cancel(id: _progressNotificationId);
      return;
    }

    await _showProgress(session, now);

    if (session.status != FastingStatus.running) return;
    if (session.goalReachedAt(now)) return;

    final targetEndAt = session.targetEndAt;
    if (targetEndAt == null) return;

    final l10n = _messages();
    await _plugin.zonedSchedule(
      id: _goalNotificationId,
      title: l10n.notificationGoalTitle,
      body: l10n.notificationGoalBody,
      scheduledDate: tz.TZDateTime.from(targetEndAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: _androidNotificationDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _ensureInitialized();
    for (final id in [
      _startNotificationId,
      _goalNotificationId,
      _progressNotificationId,
    ]) {
      await _plugin.cancel(id: id);
    }
  }

  /// Keeps the elapsed time visible outside the app.
  ///
  /// Android counts the time from `when`, so the notification stays correct
  /// without the app running. Paused fasts show the frozen elapsed time.
  Future<void> _showProgress(FastingSession session, DateTime now) {
    final l10n = _messages();
    final running = session.status == FastingStatus.running;
    final hours = session.target.inHours;

    return _plugin.show(
      id: _progressNotificationId,
      title: running
          ? (session.goalReachedAt(now)
                ? l10n.goalReached
                : l10n.notificationFastingTitle)
          : l10n.notificationPausedTitle,
      body: running
          ? l10n.goalWithHours(hours)
          : l10n.notificationPausedBody(
              formatHoursMinutes(session.elapsedAt(now)),
              hours,
            ),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _progressChannelId,
          _progressChannelName,
          channelDescription: _progressChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: running,
          usesChronometer: running,
          when: running
              ? session.startedAt
                    .add(session.totalPaused)
                    .millisecondsSinceEpoch
              : null,
        ),
      ),
    );
  }

  Future<void> _ensureInitialized() async {
    final initialization = _initialization ??= _initializePlugin();
    try {
      await initialization;
    } catch (_) {
      // Forget the failed attempt so the next sync can try again.
      _initialization = null;
      rethrow;
    }
  }

  Future<void> _initializePlugin() async {
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        // A notification icon must be a white silhouette on transparency.
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
    );
  }
}

final fastingNotificationServiceProvider = Provider<FastingNotificationService>(
  (ref) => LocalFastingNotificationService(),
);
