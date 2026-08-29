import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/db.dart';
import '../logger.dart';
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
          db.settings.platform.windowPosition = List.from(call.arguments['pos']);
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
      onTop ??= db.settings.platform.alwaysOnTop;
      return kMethodChannel
          .invokeMethod<bool?>('alwaysOnTop', <String, dynamic>{'onTop': onTop})
          .then((value) => print('alwaysOnTop success = $value'));
    }
  }

  static Future<void> setWindowPos([dynamic rect]) async {
    if (PlatformU.isWindows) {
      rect ??= db.settings.platform.windowPosition;
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

  /// Silent probe of the Android install capability:
  /// [InstallCapability.declared] gates all direct-install UI;
  /// [InstallCapability.granted] is verified per flow;
  /// [InstallCapability.manufacturer] feeds vendor guidance.
  static Future<InstallCapability?> getInstallCapability() async {
    assert(PlatformU.isAndroid);
    if (!PlatformU.isAndroid) return null;
    try {
      final result = await kMethodChannel.invokeMethod<Map>('installCapability');
      if (result == null) return null;
      return InstallCapability(
        declared: result['declared'] == true,
        granted: result['granted'] == true,
        manufacturer: result['manufacturer'] as String? ?? '',
      );
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
    } on PlatformException catch (e, s) {
      logger.e('Install apk failed', e, s);
      return false;
    }
  }

  /// Preflight-parse an XAPK: returns the manifest summary the install
  /// page shows before the user taps Install. Throws [PlatformException]
  /// with code FILE_NOT_FOUND / NOT_ZIP / NO_MANIFEST / NO_BASE_SPLIT /
  /// MISSING_SPLIT / SIZE_MISMATCH on invalid files.
  static Future<XapkManifestInfo?> parseXapk(String path) async {
    assert(PlatformU.isAndroid);
    if (!PlatformU.isAndroid) return null;
    final result = await kMethodChannel.invokeMethod<Map>('xapkParse', path);
    if (result == null) return null;
    return XapkManifestInfo.fromMap(Map<String, dynamic>.from(result));
  }

  /// Start the native XAPK install flow (ADR 0004). Returns as soon as
  /// the flow starts; states stream through [xapkEvents].
  static Future<bool> installXapk(String path) async {
    assert(PlatformU.isAndroid);
    if (!PlatformU.isAndroid) return false;
    try {
      return await kMethodChannel.invokeMethod<bool>('xapkInstall', path) ?? false;
    } on PlatformException catch (e, s) {
      // keep the bool contract; log the native error for debugging
      logger.e('xapkInstall failed: ${e.code} ${e.message}', e, s);
      return false;
    }
  }

  /// XAPK install state stream backed by the `chaldea.narumi.cc/xapk`
  /// EventChannel. Emits [XapkInstallEvent]s; replays the current
  /// state on (re)subscription.
  static Stream<XapkInstallEvent> get xapkEvents {
    _xapkEvents ??= const EventChannel(
      'chaldea.narumi.cc/xapk',
    ).receiveBroadcastStream().map((dynamic e) => XapkInstallEvent.fromMap(Map<String, dynamic>.from(e as Map)));
    return _xapkEvents!;
  }

  static Stream<XapkInstallEvent>? _xapkEvents;
}

class XapkManifestInfo {
  final String packageName;
  final String appName;
  final String versionName;
  final int versionCode;
  final int minSdk;
  final int totalSize;
  final bool hasObb;
  final List<XapkSplitInfo> splits;
  final List<String> selectedFiles;
  final List<String> deviceAbis;

  /// PNG base64 of the app default icon, when extractable from the XAPK.
  final String? appIcon;
  final Uint8List? appIconBytes;

  XapkManifestInfo({
    required this.packageName,
    required this.appName,
    required this.versionName,
    required this.versionCode,
    required this.minSdk,
    required this.totalSize,
    required this.hasObb,
    required this.splits,
    required this.selectedFiles,
    required this.deviceAbis,
    this.appIcon,
  }) : appIconBytes = _decodeIcon(appIcon);

  static Uint8List? _decodeIcon(String? str) {
    if (str == null) return null;
    try {
      return base64Decode(str);
    } catch (e, s) {
      logger.e('decode app icon base64 failed', e, s);
      return null;
    }
  }

  factory XapkManifestInfo.fromMap(Map<String, dynamic> map) {
    return XapkManifestInfo(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      versionName: map['versionName'] as String? ?? '',
      versionCode: (map['versionCode'] as num?)?.toInt() ?? -1,
      minSdk: (map['minSdk'] as num?)?.toInt() ?? 0,
      totalSize: (map['totalSize'] as num?)?.toInt() ?? 0,
      hasObb: map['hasObb'] == true,
      splits: [
        for (final s in (map['splits'] as List? ?? <dynamic>[]))
          XapkSplitInfo.fromMap(Map<String, dynamic>.from(s as Map)),
      ],
      selectedFiles: [for (final f in (map['selectedFiles'] as List? ?? <dynamic>[])) f.toString()],
      deviceAbis: [for (final a in (map['deviceAbis'] as List? ?? <dynamic>[])) a.toString()],
      appIcon: map['appIcon'] as String?,
    );
  }
}

class XapkSplitInfo {
  final String file;
  final String id;
  final int size;

  const XapkSplitInfo({required this.file, required this.id, required this.size});

  factory XapkSplitInfo.fromMap(Map<String, dynamic> map) {
    return XapkSplitInfo(
      file: map['file'] as String? ?? '',
      id: map['id'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
    );
  }
}

enum XapkInstallPhase {
  parsing,
  installing,
  confirming,
  success,
  failed;

  static XapkInstallPhase fromName(String? name) {
    return XapkInstallPhase.values.firstWhere((e) => e.name == name, orElse: () => XapkInstallPhase.failed);
  }
}

class XapkInstallEvent {
  final XapkInstallPhase phase;
  final double? progress;
  final int? bytes;
  final int? totalBytes;
  final String? error;
  final String? message;

  const XapkInstallEvent({required this.phase, this.progress, this.bytes, this.totalBytes, this.error, this.message});

  factory XapkInstallEvent.fromMap(Map<String, dynamic> map) {
    return XapkInstallEvent(
      phase: XapkInstallPhase.fromName(map['phase'] as String?),
      progress: (map['progress'] as num?)?.toDouble(),
      bytes: (map['bytes'] as num?)?.toInt(),
      totalBytes: (map['totalBytes'] as num?)?.toInt(),
      error: map['error'] as String?,
      message: map['message'] as String?,
    );
  }
}

class InstallCapability {
  /// The running build's manifest declares REQUEST_INSTALL_PACKAGES.
  final bool declared;

  /// The user allowed "install unknown apps" for this app
  /// (always true on Android < 8, where the app-op does not exist).
  final bool granted;

  /// Build.MANUFACTURER (lowercased for matching), for vendor guidance.
  final String manufacturer;

  const InstallCapability({required this.declared, required this.granted, this.manufacturer = ''});
}
