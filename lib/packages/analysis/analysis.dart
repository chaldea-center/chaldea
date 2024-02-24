import 'dart:async';

import '../platform/platform.dart';

import './analysis_impl.dart'; // f-droid-rm

class AppAnalysis {
  static AppAnalysis instance = AppAnalysis._instantiate();
  AppAnalysis._();
  factory AppAnalysis._instantiate() {
    if (PlatformU.isAndroid || PlatformU.isIOS) {
      return AppAnalysisImpl(); // f-droid-rm
    }
    return AppAnalysis._();
  }
  static final bool isSupported = PlatformU.isAndroid || PlatformU.isIOS;

  Future<void> initiate() => Future.value();
  Future<String?> startView(String? viewName) => Future.value();
  Future<void> stopView(FutureOr<String?> viewId) => Future.value();
  Future<void> reportError(dynamic error, dynamic stackTrace) => Future.value();
  Future<void> logEvent(String eventId, [Map<String, String>? attributes]) => Future.value();
}
