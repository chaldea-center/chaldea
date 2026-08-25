import 'package:flutter/services.dart';

import '../../models/db.dart';
import '../platform/platform.dart';

// default channel
const MethodChannel kMethodChannel = MethodChannel('chaldea.narumi.cc/chaldea');

class MethodChannelChaldea {
  static void configMethodChannel() {
    kMethodChannel.setMethodCallHandler((call) async {
      print('[dart] on call: ${call.method}, ${call.arguments}');
      if (call.method == 'onWindowPos') {
        if (call.arguments != null && call.arguments['pos'] != null) {
          // print('onWindowRect: args=${call.arguments}');
          db.settings.windowPosition = List.from(call.arguments['pos']);
          return;
        } else {
          print('onWindowRect invalid args=${call.arguments}');
          return;
        }
      }
    });
  }

  /// Send app to background rather exit when pop root route
  ///
  /// only available on Android
  static Future<void> sendBackground() async {
    assert(PlatformU.isAndroid);
    if (PlatformU.isAndroid) {
      return kMethodChannel.invokeMethod('sendBackground');
    }
  }

  @Deprecated('use [windowManager]')
  static Future<void> setAlwaysOnTop([bool? onTop]) async {
    if (PlatformU.isWindows || PlatformU.isMacOS) {
      onTop ??= db.settings.alwaysOnTop;
      return kMethodChannel
          .invokeMethod<bool?>('alwaysOnTop', <String, dynamic>{'onTop': onTop})
          .then((value) => print('alwaysOnTop success = $value'));
    }
  }

  static Future<void> setWindowPos([dynamic rect]) async {
    if (PlatformU.isWindows) {
      rect ??= db.settings.windowPosition;
      print('rect ${rect.runtimeType}: $rect');
      if (rect != null && rect is List && rect.length == 4 && rect.any((e) => e is int && e > 0)) {
        print('ready to set window rect: $rect');
        return kMethodChannel.invokeMethod('setWindowRect', <String, dynamic>{'pos': rect});
      }
    }
  }

  static Future<String?> getUserAgent() async {
    assert(PlatformU.isAndroid);
    if (PlatformU.isAndroid) {
      return kMethodChannel.invokeMethod('getUserAgent');
    }
    return null;
  }

  static Future<String?> getCFNetworkVersion() async {
    assert(PlatformU.isIOS);
    if (PlatformU.isIOS) {
      return kMethodChannel.invokeMethod('getCFNetworkVersion');
    }
    return null;
  }

  /// Silent probe of the Android install capability (see docs/adr/0003):
  /// [InstallCapability.declared] gates all direct-install UI;
  /// [InstallCapability.granted] is verified per flow.
  static Future<InstallCapability?> getInstallCapability() async {
    assert(PlatformU.isAndroid);
    if (!PlatformU.isAndroid) return null;
    try {
      final result = await kMethodChannel.invokeMethod<Map>('installCapability');
      if (result == null) return null;
      return InstallCapability(declared: result['declared'] == true, granted: result['granted'] == true);
    } on PlatformException {
      return null;
    }
  }

  /// Deep-link to this app's "install unknown apps" system settings page.
  static Future<void> openInstallPermissionSettings() async {
    assert(PlatformU.isAndroid);
    if (PlatformU.isAndroid) {
      await kMethodChannel.invokeMethod('openInstallPermissionSettings');
    }
  }

  /// Hand a downloaded APK file to the system package installer.
  static Future<bool> installApk(String path) async {
    assert(PlatformU.isAndroid);
    if (!PlatformU.isAndroid) return false;
    try {
      return await kMethodChannel.invokeMethod<bool>('installApk', path) ?? false;
    } on PlatformException {
      return false;
    }
  }
}

class InstallCapability {
  /// The running build's manifest declares REQUEST_INSTALL_PACKAGES.
  final bool declared;

  /// The user allowed "install unknown apps" for this app
  /// (always true on Android < 8, where the app-op does not exist).
  final bool granted;

  const InstallCapability({required this.declared, required this.granted});
}
