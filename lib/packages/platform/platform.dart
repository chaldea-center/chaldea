import 'dart:io';

import 'package:flutter/foundation.dart';

import 'platform_io.dart' if (dart.library.js) 'platform_web.dart';

class PlatformU {
  const PlatformU._();

  static const bool isWeb = kIsWeb;
  static final bool isLinux = !kIsWeb && Platform.isLinux;
  static final bool isMacOS = !kIsWeb && Platform.isMacOS;
  static final bool isWindows = !kIsWeb && Platform.isWindows;
  static final bool isAndroid = !kIsWeb && Platform.isAndroid;
  static final bool isIOS = !kIsWeb && Platform.isIOS;
  static final bool isFuchsia = !kIsWeb && Platform.isFuchsia;

  // extra
  static final bool isMobile = isAndroid || isIOS;
  static final bool isDesktop = isWindows || isMacOS || isLinux;
  static final bool isDesktopOrWeb = isDesktop || isWeb;
  static final bool isApple = isIOS || isMacOS;

  static final String operatingSystem = kIsWeb ? 'browser' : Platform.operatingSystem;
  static final String operatingSystemVersion = kIsWeb ? '' : Platform.operatingSystemVersion;
  static final String resolvedExecutable = kIsWeb
      ? throw UnimplementedError('Not for web')
      : Platform.resolvedExecutable;

  static bool get isTargetMobile => [TargetPlatform.android, TargetPlatform.iOS].contains(defaultTargetPlatform);
  static bool get isTargetDesktop => !isTargetMobile;

  // plugin supports
  static final bool supportCopyImage =
      kIsWeb || Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isAndroid;
}

final kPlatformMethods = PlatformMethods();
