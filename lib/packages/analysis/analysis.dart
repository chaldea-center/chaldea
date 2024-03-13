import 'dart:async';

import '../platform/platform.dart';
import './analysis_impl.dart';

class AppAnalysis {
  static AppAnalysis instance = AppAnalysis._instantiate();
  AppAnalysis._();
  factory AppAnalysis._instantiate() {
    if (PlatformU.isAndroid || PlatformU.isIOS) {
      return AppAnalysisImpl();
    }
    return AppAnalysis._();
  }
  static final bool isSupported = PlatformU.isAndroid || PlatformU.isIOS;

  Future<void> initiate() => Future.value();
  Future<String?> startView(String? viewName) => Future.value();
  Future<void> stopView(FutureOr<String?> viewId) => Future.value();
  Future<void> reportError(dynamic error, dynamic stackTrace) => Future.value();
  Future<void> logEvent(String eventId, [Map<String, String>? attributes]) => Future.value();

  static (String baseRoute, String subpath) splitViewName(String viewName) {
    final queryIndex = viewName.indexOf('?');
    if (queryIndex >= 0) {
      viewName = viewName.substring(0, queryIndex);
    }

    if (viewName.isEmpty) return (viewName, "");

    String? baseRoute;

    for (final category in const ['buffAction', 'summon', 'script']) {
      final route = '/$category/';
      if (viewName.startsWith(route)) {
        baseRoute = route;
        break;
      }
    }
    baseRoute ??= viewName;
    final match = RegExp(r'^(/.+?)(\-?\d+/)*\-?\d+$').firstMatch(baseRoute);
    baseRoute = match?.group(1) ?? baseRoute;
    assert(viewName.startsWith(baseRoute), '$viewName -> $baseRoute');
    String subpath = viewName.startsWith(baseRoute) ? viewName.substring(baseRoute.length) : "";
    if (baseRoute.isEmpty) return (viewName, "");
    return (baseRoute, subpath);
  }
}
