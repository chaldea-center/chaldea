import 'platform_type.dart';
import 'platform_web.dart' if (dart.library.io) 'platform_io.dart';

class PlatformU {
  static final bool isWeb = currentPlatform == PlatformType.web;
  static final bool isLinux = currentPlatform == PlatformType.linux;
  static final bool isMacOS = currentPlatform == PlatformType.macOS;
  static final bool isWindows = currentPlatform == PlatformType.windows;
  static final bool isAndroid = currentPlatform == PlatformType.android;
  static final bool isIOS = currentPlatform == PlatformType.iOS;
  static final bool isFuchsia = currentPlatform == PlatformType.fuchsia;

  // extra
  static final bool isMobile = isAndroid || isIOS;
  static final bool isDesktop = isWindows || isMacOS || isLinux;
  static final bool isDesktopOrWeb = isDesktop || isWeb;
  static final bool isApple = isIOS || isMacOS;

  static final String operatingSystem = currentOperatingSystem;
  static final String operatingSystemVersion = currentOperatingSystemVersion;
  static final String resolvedExecutable = currentResolvedExecutable;
}
