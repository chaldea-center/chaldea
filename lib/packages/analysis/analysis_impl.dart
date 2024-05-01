import 'dart:async';

import 'package:countly_flutter_np/countly_flutter.dart';

import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/platform/platform.dart';
import '../../models/db.dart';
import '../app_info.dart';
import '../language.dart';
import 'analysis.dart';

class AppAnalysisImpl implements AppAnalysis {
  @override
  Future<void> initiate() async {
    final isInitialized = await Countly.isInitialized();
    if (!isInitialized) {
      CountlyConfig config =
          CountlyConfig("https://countly.chaldea.center", '46e56e032869aa7dc7e8627bfb6b00c4f0dc1b41');
      // if (kDebugMode) config.setLoggingEnabled(true);
      // after db init
      config
        ..setUserProperties({
          "language": Language.current.code,
          "region": db.settings.resolvedPreferredRegions.firstOrNull?.upper,
          "channel": PlatformU.isAndroid
              ? (AppInfo.isFDroid ? 'f-droid' : 'android')
              : PlatformU.isIOS
                  ? 'ios'
                  : "unknown"
        })
        ..setUpdateSessionTimerDelay(600)
        ..setEventQueueSizeToSend(50);
      await Countly.initWithConfig(config);
      // print('Countly init: $msg');
    }
  }

  @override
  Future<void> reportError(error, stackTrace) {
    return Future.value();
  }

  @override
  Future<String?> startView(String? viewName) async {
    if (viewName == null) return null;
    final (baseRoute, subpath) = AppAnalysis.splitViewName(viewName);
    if (baseRoute.isEmpty) return null;
    final viewId = await Countly.instance.views.startView(baseRoute, {if (subpath.isNotEmpty) "id": subpath});
    return viewId;
  }

  @override
  Future<void> stopView(FutureOr<String?> viewId) async {
    String? _viewId;
    if (viewId is Future) {
      _viewId = await viewId;
    } else {
      _viewId = viewId;
    }
    if (_viewId != null && _viewId.isNotEmpty) {
      await Countly.instance.views.stopViewWithID(_viewId);
    }
  }

  @override
  Future<void> logEvent(String eventId, [Map<String, String>? attributes]) {
    return Countly.recordEvent({
      "key": eventId,
      "count": 1,
      if (attributes != null && attributes.isNotEmpty) "segmentation": attributes,
    });
  }
}
