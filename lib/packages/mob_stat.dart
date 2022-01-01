import 'package:baidu_mob_stat/baidu_mob_stat.dart';
import 'package:flutter/foundation.dart';

import 'platform/platform.dart';

const _apiKeyIOS = 'bf8a02d588';
const _apiKeyAndroid = '714a13d204';

abstract class MobStat {
  static final bool _validPlatform = PlatformU.isMobile;

  static void start({
    bool debug = kDebugMode,
    int delay = 0,
    int session = 30,
    bool browseMode = false,
  }) {
    if (!_validPlatform) return;
    String appId = PlatformU.isIOS ? _apiKeyIOS : _apiKeyAndroid;
    BaiduMobStatFlutter.start(
      appId: appId,
      debug: debug,
      delay: delay,
      session: session,
      browseMode: browseMode,
    );
  }

  static void logEvent(String eventId, [Map<String, String>? attributes]) {
    if (!_validPlatform) return;
    // flutter 2.7.0: org.json.jsonobject$1 cannot be cast to org.json.jsonobject
    // BaiduMobStatFlutter.logEvent(eventId, attributes);
  }

  static void logDurationEvent(String eventId, int duration,
      [Map<String, String>? attributes]) {
    if (!_validPlatform) return;
    BaiduMobStatFlutter.logDurationEvent(eventId, duration, attributes);
  }

  static void eventStart(String eventId) {
    if (!_validPlatform) return;
    BaiduMobStatFlutter.eventStart(eventId);
  }

  static void eventEnd(String eventId, [Map<String, String>? attributes]) {
    if (!_validPlatform) return;
    BaiduMobStatFlutter.eventEnd(eventId, attributes);
  }

  static void pageStart(String name) {
    if (!_validPlatform) return;
    BaiduMobStatFlutter.pageStart(name);
  }

  static void pageEnd(String name) {
    if (!_validPlatform) return;
    BaiduMobStatFlutter.pageEnd(name);
  }
}
