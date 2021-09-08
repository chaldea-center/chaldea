import 'dart:io';

import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'config.dart' show db;
import 'constants.dart';
import 'git_tool.dart';
import 'logger.dart';

class AppInfo {
  AppInfo._();

  static PackageInfo? _packageInfo;
  static String? _uuid;
  static MacAppType _macAppType = MacAppType.unknown;
  static bool _isIPad = false;
  static int? _androidSdk;

  static final Map<String, dynamic> deviceParams = {};
  static final Map<String, dynamic> appParams = {};

  static Future<void> _loadDeviceInfo() async {
    if (PlatformU.isAndroid) {
      _loadAndroidParameters(await DeviceInfoPlugin().androidInfo);
    } else if (PlatformU.isIOS) {
      _loadIosParameters(await DeviceInfoPlugin().iosInfo);
    } else {
      deviceParams['operatingSystem'] = PlatformU.operatingSystem;
      deviceParams['operatingSystemVersion'] = PlatformU.operatingSystemVersion;
      // To be implemented
    }
  }

  static void _loadAndroidParameters(AndroidDeviceInfo androidDeviceInfo) {
    deviceParams["id"] = androidDeviceInfo.id;
    deviceParams["androidId"] = androidDeviceInfo.androidId;
    deviceParams["board"] = androidDeviceInfo.board;
    deviceParams["bootloader"] = androidDeviceInfo.bootloader;
    deviceParams["brand"] = androidDeviceInfo.brand;
    deviceParams["device"] = androidDeviceInfo.device;
    deviceParams["display"] = androidDeviceInfo.display;
    deviceParams["fingerprint"] = androidDeviceInfo.fingerprint;
    deviceParams["hardware"] = androidDeviceInfo.hardware;
    deviceParams["host"] = androidDeviceInfo.host;
    deviceParams["isPhysicalDevice"] = androidDeviceInfo.isPhysicalDevice;
    deviceParams["manufacturer"] = androidDeviceInfo.manufacturer;
    deviceParams["model"] = androidDeviceInfo.model;
    deviceParams["product"] = androidDeviceInfo.product;
    deviceParams["tags"] = androidDeviceInfo.tags;
    deviceParams["type"] = androidDeviceInfo.type;
    deviceParams["versionBaseOs"] = androidDeviceInfo.version.baseOS;
    deviceParams["versionCodename"] = androidDeviceInfo.version.codename;
    deviceParams["versionIncremental"] = androidDeviceInfo.version.incremental;
    deviceParams["versionPreviewSdk"] = androidDeviceInfo.version.previewSdkInt;
    deviceParams["versionRelease"] = androidDeviceInfo.version.release;
    deviceParams["versionSdk"] = androidDeviceInfo.version.sdkInt;
    deviceParams["versionSecurityPatch"] =
        androidDeviceInfo.version.securityPatch;

    _androidSdk = androidDeviceInfo.version.sdkInt;
  }

  static void _loadIosParameters(IosDeviceInfo iosInfo) {
    deviceParams["model"] = iosInfo.model;
    deviceParams["isPhysicalDevice"] = iosInfo.isPhysicalDevice;
    deviceParams["name"] = iosInfo.name;
    deviceParams["identifierForVendor"] = iosInfo.identifierForVendor;
    deviceParams["localizedModel"] = iosInfo.localizedModel;
    deviceParams["systemName"] = iosInfo.systemName;
    deviceParams["utsnameVersion"] = iosInfo.utsname.version;
    deviceParams["utsnameRelease"] = iosInfo.utsname.release;
    deviceParams["utsnameMachine"] = iosInfo.utsname.machine;
    deviceParams["utsnameNodename"] = iosInfo.utsname.nodename;
    deviceParams["utsnameSysname"] = iosInfo.utsname.sysname;

    // extra
    _isIPad = iosInfo.model?.toLowerCase().contains('ipad') ?? false;
  }

  /// PackageInfo: appName+version+buildNumber
  ///  - Android: support
  ///  - for iOS/macOS:
  ///   - if CF** keys not defined in info.plist, return null
  ///   - if buildNumber not defined, return version instead
  ///  - Windows: Not Support
  static Future<void> _loadApplicationInfo() async {
    ///Only android, iOS and macOS are implemented
    _packageInfo = PlatformU.isWindows
        ? await _loadApplicationInfoFromAsset()
        : await PackageInfo.fromPlatform()
            .catchError((e) => _loadApplicationInfoFromAsset());
    // if (kDebugMode) {
    //   _packageInfo = PackageInfo(
    //     appName: 'Chaldea',
    //     packageName: 'cc.narumi.cc',
    //     version: '1.4.8',
    //     buildNumber: '2048',
    //     buildSignature: '',
    //   );
    // }
    appParams["version"] = _packageInfo?.version;
    appParams["appName"] = _packageInfo?.appName;
    appParams["buildNumber"] = _packageInfo?.buildNumber;
    appParams["packageName"] = _packageInfo?.packageName;
  }

  static Future<PackageInfo> _loadApplicationInfoFromAsset() async {
    final versionString = await rootBundle.loadString('res/VERSION');
    final nameAndCode = versionString.split('+');
    PackageInfo packageInfo = PackageInfo(
      appName: kAppName,
      packageName: kPackageName,
      version: nameAndCode[0],
      buildNumber: nameAndCode[1],
      buildSignature: '',
    );
    logger.i('Fail to read package info, asset instead: $nameAndCode');
    return packageInfo;
  }

  static Future<void> _loadUniqueId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String? originId;
    if (PlatformU.isWeb) {
      originId = null;
      _uuid = '00000000-0000-0000-0000-000000000000';
      return;
    }
    if (PlatformU.isAndroid) {
      originId = (await deviceInfoPlugin.androidInfo).androidId;
    } else if (PlatformU.isIOS) {
      originId = (await deviceInfoPlugin.iosInfo).identifierForVendor;
    } else if (PlatformU.isWindows) {
      // reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductId"
      // Output:
      // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
      //     ProductId    REG_SZ    XXXXX-XXXXX-XXXXX-XXXXX
      final result = await Process.run(
        'reg',
        [
          'query',
          // ProductId
          // r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion',
          // MachineGuid
          r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography',
          '/v',
          // 'ProductId'
          'MachineGuid'
        ],
        runInShell: true,
      );
      String resultString = result.stdout.toString().trim();
      // print('Windows MachineGuid query:\n$resultString');
      if (resultString.contains('MachineGuid') &&
          resultString.contains('REG_SZ')) {
        originId = resultString.trim().split(RegExp(r'\s+')).last;
      }
    } else if (PlatformU.isMacOS) {
      // https://stackoverflow.com/a/944103
      // However, IOPlatformUUID will change every boot, use IOPlatformSerialNumber instead
      // ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }'
      // the filter is shell feature so it's not used
      // Output containing:
      //  "IOPlatformUUID" = "8-4-4-4-12 standard uuid"
      // need to parse output
      final result = await Process.run(
        'ioreg',
        [
          '-rd1',
          '-c',
          'IOPlatformExpertDevice',
        ],
        runInShell: true,
      );
      for (String line in result.stdout.toString().split('\n')) {
        if (line.contains('IOPlatformSerialNumber')) {
          final _snMatches =
              RegExp(r'[0-9a-zA-Z\-]+').allMatches(line).toList();
          if (_snMatches.isNotEmpty) {
            final _sn = _snMatches.last.group(0);
            if (_sn != null) {
              originId = _sn;
              break;
            }
          }
        }
      }
    } else {
      throw UnimplementedError(PlatformU.operatingSystem);
    }
    if (originId?.isNotEmpty != true) {
      var uuidFile = File(p.join(db.paths.appPath, '.uuid'));
      if (uuidFile.existsSync()) {
        originId = uuidFile.readAsStringSync();
      }
      if (originId?.isNotEmpty != true) {
        originId = Uuid().v1();
        uuidFile.writeAsStringSync(_uuid!);
      }
    }
    _uuid = Uuid().v5(Uuid.NAMESPACE_URL, originId!).toUpperCase();

    logger.i('Unique ID: $_uuid');
  }

  /// resolve when init app, so no need to check null or resolve every time
  /// TODO: wait official support for windows
  static Future<void> resolve() async {
    await _loadDeviceInfo();
    await _loadApplicationInfo();
    await _loadUniqueId();
    _checkMacAppType();
  }

  static void _checkMacAppType() {
    if (!PlatformU.isMacOS) {
      _macAppType = MacAppType.notMacApp;
    } else {
      final String executable = PlatformU.resolvedExecutable;
      final String fpStore =
          p.absolute(p.dirname(executable), '../_MASReceipt/receipt');
      final String fpNotarized =
          p.absolute(p.dirname(executable), '../CodeResources');
      if (File(fpStore).existsSync()) {
        _macAppType = MacAppType.store;
      } else if (File(fpNotarized).existsSync()) {
        _macAppType = MacAppType.notarized;
      } else {
        _macAppType = MacAppType.debug;
      }
    }
  }

  static PackageInfo? get info => _packageInfo;

  static String get appName {
    if (_packageInfo?.appName.isNotEmpty == true) {
      return _packageInfo!.appName;
    } else {
      return kAppName;
    }
  }

  static Version get versionClass => Version.tryParse(fullVersion)!;

  /// e.g. "1.2.3"
  static String get version => _packageInfo?.version ?? '';

  static int get buildNumber =>
      int.tryParse(_packageInfo?.buildNumber ?? '0') ?? 0;

  static int get originBuild {
    if (PlatformU.isAndroid) {
      final _build = buildNumber;
      if (_build > 1000 && [10, 20, 40].contains(_build ~/ 100)) {
        return int.parse(_build.toString().substring(2));
      }
    }
    return buildNumber;
  }

  static String get packageName => info?.packageName ?? kPackageName;

  static ABIType get abi {
    if (!PlatformU.isAndroid) return ABIType.unknown;
    if (buildNumber <= 100) return ABIType.unknown;
    String buildStr = buildNumber.toString();
    if (buildStr.startsWith('10')) return ABIType.armeabiV7a;
    if (buildStr.startsWith('20')) return ABIType.arm64V8a;
    if (buildStr.startsWith('40')) return ABIType.x86_64;
    return ABIType.arm64V8a;
  }

  static int? get androidSdk => _androidSdk;

  /// e.g. "1.2.3+4"
  static String get fullVersion {
    String s = '';
    s += version;
    if (buildNumber > 0) s += '+$buildNumber';
    return s;
  }

  /// e.g. "1.2.3 (4)"
  static String get fullVersion2 {
    StringBuffer buffer = StringBuffer(version);
    if (buildNumber > 0) {
      buffer.write(' ($buildNumber');
      if (PlatformU.isAndroid) {
        buffer.write(', ${EnumUtil.shortString(abi)}');
      }
      buffer.write(')');
    }
    return buffer.toString();
  }

  static String get uuid => _uuid!;

  static bool get isDebugDevice {
    const excludeIds = [
      'FB26CA34-0B8F-588C-8542-4A748BB67740', // android
      '739F2CE5-ADA0-5216-B6C9-CBF1D1C33183', // ios
      '1D6D5558-9929-5AB0-9CE7-BC2E188948CD', // macos
      '6986A299-F7CB-5BBF-9680-14ED34013C07', // windows
    ];
    return excludeIds.contains(AppInfo.uuid);
  }

  static bool get isIPad => _isIPad;

  static MacAppType get macAppType => _macAppType;

  static bool get isMacStoreApp => _macAppType == MacAppType.store;
}

enum MacAppType {
  unknown,
  store,
  notarized,
  debug,
  notMacApp,
}

enum ABIType {
  unknown,
  arm64V8a,
  armeabiV7a,
  x86_64,
}

extension ABITypeToString on ABIType {
  String toStandardString() {
    switch (this) {
      case ABIType.unknown:
        return 'unknown';
      case ABIType.arm64V8a:
        return 'arm64-v8a';
      case ABIType.armeabiV7a:
        return 'armeabi-v7a';
      case ABIType.x86_64:
        return 'x86_64';
    }
  }
}
