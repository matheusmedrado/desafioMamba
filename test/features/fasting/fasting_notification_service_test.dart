import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const notificationChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezoneChannel = MethodChannel('flutter_timezone');
  final log = <MethodCall>[];

  setUp(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(notificationChannel, (call) async {
        log.add(call);
        if (call.method == 'initialize') return true;
        return null;
      })
      ..setMockMethodCallHandler(timezoneChannel, (call) async {
        expect(call.method, 'getLocalTimezone');
        return 'Etc/UTC';
      });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(notificationChannel, null)
      ..setMockMethodCallHandler(timezoneChannel, null);
  });

  final startedAt = DateTime.utc(2099, 9, 10, 8);

  FastingSession session() {
    return FastingSession.start(
      id: 'fast-1',
      protocolId: '16:8',
      target: const Duration(hours: 16),
      startedAt: startedAt,
    );
  }

  test(
    'shows start and schedules the fasting goal in the device timezone',
    () async {
      final service = LocalFastingNotificationService();

      await service.showFastStarted();
      await service.sync(session(), startedAt);

      expect(log.map((call) => call.method), [
        'initialize',
        'requestNotificationsPermission',
        'show',
        'cancel',
        'zonedSchedule',
      ]);

      final start = log.singleWhere((call) => call.method == 'show');
      expect((start.arguments as Map)['id'], 1001);
      expect((start.arguments as Map)['title'], 'Fast started');

      final scheduled = log.singleWhere(
        (call) => call.method == 'zonedSchedule',
      );
      final arguments = Map<String, Object?>.from(scheduled.arguments as Map);
      expect(arguments['id'], 1002);
      expect(arguments['timeZoneName'], 'Etc/UTC');
      expect(
        DateTime.parse(arguments['scheduledDateTimeISO8601']! as String)
            .toUtc(),
        startedAt.add(const Duration(hours: 16)),
      );
      final platformSpecifics = Map<String, Object?>.from(
        arguments['platformSpecifics']! as Map,
      );
      expect(platformSpecifics['scheduleMode'], 'inexactAllowWhileIdle');
    },
  );

  test('cancels without scheduling when the target is reached', () async {
    final service = LocalFastingNotificationService();

    await service.sync(session(), startedAt.add(const Duration(hours: 16)));

    expect(log.map((call) => call.method), ['initialize', 'cancel']);
  });

  test('cancels without scheduling when there is no active session', () async {
    final service = LocalFastingNotificationService();

    await service.sync(null, startedAt);

    expect(log.map((call) => call.method), ['initialize', 'cancel']);
  });

  test('reschedules the goal after a pause and resume', () async {
    final service = LocalFastingNotificationService();
    final paused = session().pauseAt(startedAt.add(const Duration(hours: 2)));
    await service.sync(paused, startedAt.add(const Duration(hours: 7)));

    log.clear();
    final resumed = paused.resumeAt(startedAt.add(const Duration(hours: 7)));
    await service.sync(resumed, startedAt.add(const Duration(hours: 7)));

    expect(log.map((call) => call.method), ['cancel', 'zonedSchedule']);
    final scheduled = log.singleWhere((call) => call.method == 'zonedSchedule');
    final arguments = Map<String, Object?>.from(scheduled.arguments as Map);
    expect(arguments['id'], 1002);
    expect(
      DateTime.parse(arguments['scheduledDateTimeISO8601']! as String).toUtc(),
      startedAt.add(const Duration(hours: 21)),
    );
  });

  test('cancels without scheduling while paused or ended', () async {
    final service = LocalFastingNotificationService();
    final paused = session().pauseAt(startedAt.add(const Duration(hours: 2)));

    await service.sync(paused, startedAt.add(const Duration(hours: 8)));
    expect(log.map((call) => call.method), ['initialize', 'cancel']);

    log.clear();
    final ended = session().endAt(startedAt.add(const Duration(hours: 4)));
    await service.sync(ended, startedAt.add(const Duration(hours: 4)));
    expect(log.map((call) => call.method), ['cancel']);
  });
}
