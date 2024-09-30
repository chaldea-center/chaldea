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
    try {
      await _configureLocalTimeZone();
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentSound: false,
      );
      await plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_launcher'),
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (NotificationResponse resp) {
          print(
              'onDidReceiveNotificationResponse: ${resp.id},${resp.actionId},${resp.notificationResponseType},${resp.input},${resp.payload}');
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (e, s) {
      logger.e('init local notification failed', e, s);
    }
  }

  static Future<bool?> requestPermissions() async {
    if (kIsWeb) return null;
    if (Platform.isIOS) {
      return plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isMacOS) {
      return plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      return androidImplementation?.requestExactAlarmsPermission();
    }
    return null;
  }

  static const _defaultAndroidDetails = AndroidNotificationDetails(
    'chaldea_common',
    'Chaldea Common',
    channelDescription: 'Chaldea Common',
    importance: Importance.max,
    priority: Priority.high,
  );

  static Future<void> showNotification({
    int? id,
    required String? title,
    required String? body,
  }) async {
    return plugin.show(
      id ?? _id++,
      title,
      body,
      const NotificationDetails(android: _defaultAndroidDetails),
    );
  }

  static Future<void> scheduleNotification({
    int? id,
    required DateTime dateTime,
    required String? title,
    required String? body,
    bool autoCancelPrevious = true,
  }) async {
    if (id != null && autoCancelPrevious) {
      await plugin.cancel(id);
    }
    return plugin.zonedSchedule(
      id ?? _id++,
      title,
      body,
      tz.TZDateTime.from(dateTime, _hasLocalTz ? tz.local : tz.UTC),
      const NotificationDetails(android: _defaultAndroidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static bool _hasLocalTz = false;
  static Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      _hasLocalTz = true;
    } catch (e, s) {
      FlutterError.dumpErrorToConsole(FlutterErrorDetails(exception: e, stack: s));
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse resp) {
    print('notification(${resp.id}) action tapped: '
        '${resp.actionId} with'
        ' payload: ${resp.payload}');
    if (resp.input?.isNotEmpty ?? false) {
      print('notification action tapped with input: ${resp.input}');
    }
  }

  static const int _kUserIdMod = 10 ^ 5;
  static int generateUserApRecoverId(int region, int userId, int ap) {
    // 1+3+17+8=29 bits
    int v = 1;
    v = (v << 3) + region;
    v = (v << 17) + userId % _kUserIdMod;
    v = (v << 8) + ap;
    return v;
  }

  static bool isUserApFullId(int id) {
    return (id >> (3 + 17 + 8)) == 1;
  }
}
