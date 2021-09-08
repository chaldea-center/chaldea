import 'dart:io' as io;

import 'platform_type.dart';

PlatformType get currentPlatform {
  if (io.Platform.isLinux)
    return PlatformType.linux;
  else if (io.Platform.isMacOS)
    return PlatformType.macOS;
  else if (io.Platform.isWindows)
    return PlatformType.windows;
  else if (io.Platform.isAndroid)
    return PlatformType.android;
  else if (io.Platform.isIOS) return PlatformType.iOS;
  return PlatformType.fuchsia;
}

String get currentOperatingSystem => io.Platform.operatingSystem;

String get currentOperatingSystemVersion => io.Platform.operatingSystemVersion;

String get currentResolvedExecutable => io.Platform.resolvedExecutable;
