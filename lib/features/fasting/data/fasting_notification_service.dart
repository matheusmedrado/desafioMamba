import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/fasting_session.dart';

/// Notification operations needed by the fasting controller.
abstract class FastingNotificationService {
  Future<void> showFastStarted();

  Future<void> sync(FastingSession? session, DateTime now);
}

/// Local notification implementation for Android.
class LocalFastingNotificationService implements FastingNotificationService {
  LocalFastingNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _startNotificationId = 1001;
  static const _goalNotificationId = 1002;
  static const _channelId = 'fasting_updates';
  static const _channelName = 'Fasting updates';
  static const _channelDescription =
      'Notifications about the current fasting session.';
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
    await _plugin.show(
      id: _startNotificationId,
      title: 'Fast started',
      body: 'Your fasting timer is now running.',
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

    if (session == null || session.status != FastingStatus.running) return;
    if (session.goalReachedAt(now)) return;

    final targetEndAt = session.targetEndAt;
    if (targetEndAt == null) return;

    await _plugin.zonedSchedule(
      id: _goalNotificationId,
      title: 'Fasting goal reached',
      body: 'Your planned fasting window is complete.',
      scheduledDate: tz.TZDateTime.from(targetEndAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: _androidNotificationDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
        // Without the type prefix Android only searches drawable resources,
        // and the launcher icon is a mipmap.
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }
}

final fastingNotificationServiceProvider = Provider<FastingNotificationService>(
  (ref) => LocalFastingNotificationService(),
);
