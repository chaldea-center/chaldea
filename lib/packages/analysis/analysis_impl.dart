import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_baidu_mob_stat/fl_baidu_mob_stat_ys.dart';

import 'analysis.dart';

class AppAnalysisImpl implements AppAnalysis {
  static const _iOSKey = 'bf8a02d588';
  static const _androidKey = '714a13d204';

  final instance = FlBaiduMobStatYs();
  @override
  Future<void> initiate() async {
    await instance.setApiKey(androidKey: _androidKey, iosKey: _iOSKey);
    if (kDebugMode) await instance.setDebug(true);
  }

  @override
  Future<void> reportError(error, stackTrace) {
    return Future.value();
  }

  @override
  Future<String?> startView(String? viewName) async {
    if (viewName != null && viewName.isNotEmpty) {
      await instance.pageStart(viewName);
      return viewName;
    }
    return null;
  }

  @override
  Future<void> stopView(FutureOr<String?> viewName) async {
    String? _name;
    if (viewName is Future) {
      _name = await viewName;
    } else {
      _name = viewName;
    }
    if (_name != null && _name.isNotEmpty) {
      await instance.pageEnd(_name);
    }
  }

  @override
  Future<void> logEvent(String eventId, [Map<String, String>? attributes]) {
    return instance.logEvent(eventId: eventId, attributes: attributes);
  }
}
