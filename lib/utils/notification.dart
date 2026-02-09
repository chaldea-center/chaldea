// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../packages/logger.dart';

abstract class LocalNotificationUtil {
  static int _id = 0;
  static final plugin = FlutterLocalNotificationsPlugin();

  static final bool supported = !kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid);

  static Future<void> init() async {
    if (!supported) return;
    try {
      await _configureLocalTimeZone();
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentSound: false,
      );
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (NotificationResponse resp) {
          print(
            'onDidReceiveNotificationResponse: ${resp.id},${resp.actionId},${resp.notificationResponseType},${resp.input},${resp.payload}',
          );
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (e, s) {
      logger.e('init local notification failed', e, s);
    }
  }

  static bool _requested = false;
  static bool? _hasPermission;
  static bool? get hasPermission => _hasPermission;

  static Future<bool?> requestPermissions() async {
    if (!supported) return null;
    bool? result;
    if (Platform.isIOS) {
      result = await plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isMacOS) {
      result = await plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final a = await androidImplementation?.requestNotificationsPermission();
      final b = await androidImplementation?.requestExactAlarmsPermission();
      if (a == null && b == null) {
        result = null;
      } else if (a != null && b != null) {
        result = a && b;
      } else {
        result = false;
      }
    }
    _hasPermission = result;
    _requested = true;
    return result;
  }

  static Future<bool> checkPermission() async {
    if (!supported) return false;
    if (_requested) return _hasPermission ?? false;
    return (await requestPermissions()) ?? false;
  }

  static const _defaultAndroidDetails = AndroidNotificationDetails(
    'chaldea_common',
    'Chaldea Common',
    channelDescription: 'Chaldea Common',
    importance: Importance.max,
    priority: Priority.high,
  );

  static Future<void> showNotification({int? id, required String? title, required String? body}) async {
    if (!supported) return;
    return plugin.show(
      id: id ?? _id++,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _defaultAndroidDetails),
    );
  }

  static Future<void> scheduleNotification({
    int? id,
    required DateTime dateTime,
    required String? title,
    required String? body,
    bool autoCancelPrevious = true,
  }) async {
    if (!supported) return;
    if (id != null && autoCancelPrevious) {
      await plugin.cancel(id: id);
    }
    return plugin.zonedSchedule(
      id: id ?? _id++,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, _hasLocalTz ? tz.local : tz.UTC),
      notificationDetails: const NotificationDetails(android: _defaultAndroidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static bool _hasLocalTz = false;
  static Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      _hasLocalTz = true;
    } catch (e, s) {
      FlutterError.dumpErrorToConsole(FlutterErrorDetails(exception: e, stack: s));
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse resp) {
    print(
      'notification(${resp.id}) action tapped: '
      '${resp.actionId} with'
      ' payload: ${resp.payload}',
    );
    if (resp.input?.isNotEmpty ?? false) {
      print('notification action tapped with input: ${resp.input}');
    }
  }

  static const int _kUserIdMod = 10 ^ 5;
  static int generateUserApRecoverId(int region, int userId, int ap) {
    // 1   +3     +17    +8 =29 bits
    // flag+region+userId+ap
    int v = 1;
    v = (v << 3) + region;
    v = (v << 17) + userId % _kUserIdMod;
    v = (v << 8) + ap;
    return v;
  }

  static int _getBitRange(int value, int skip, int length) {
    return (value >> skip) & ((1 << length) - 1);
  }

  static bool isUserApId(int id, {int? region, int? userId, int? ap}) {
    if ((id >> (3 + 17 + 8)) != 1) return false;
    if (ap != null && ap != _getBitRange(id, 0, 8)) return false;
    if (userId != null && userId != _getBitRange(id, 8, 17)) return false;
    if (region != null && region != _getBitRange(id, 17 + 8, 3)) return false;
    return true;
  }
}
