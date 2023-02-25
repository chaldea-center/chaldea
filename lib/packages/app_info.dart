import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as pathlib;
import 'package:uuid/uuid.dart';

import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import '../generated/git_info.dart';
import '../models/userdata/version.dart';

class AppInfo {
  AppInfo._();

  static PackageInfo? _packageInfo;
  static String? _uuid;
  static bool _debugOn = false;
  static MacAppType _macAppType = MacAppType.unknown;
  static bool _isIPad = false;
  static int? _androidSdk;

  static final Map<String, dynamic> deviceParams = {};
  static final Map<String, dynamic> appParams = {};

  static Future<void> _loadDeviceInfo() async {
    try {
      if (PlatformU.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceParams
            .addAll(Map.from(androidInfo.data)..remove('systemFeatures'));
        _androidSdk = androidInfo.version.sdkInt;
        deviceParams['androidId'] = await const AndroidId().getId();
      } else if (PlatformU.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        _isIPad = iosInfo.model?.toLowerCase().contains('ipad') ?? false;
        deviceParams.addAll(Map.from(iosInfo.data)..remove('name'));
      } else if (PlatformU.isMacOS) {
        final macOsInfo = await DeviceInfoPlugin().macOsInfo;
        deviceParams.addAll(Map.from(macOsInfo.data)..remove('computerName'));
      } else if (PlatformU.isLinux) {
        final linuxInfo = await DeviceInfoPlugin().linuxInfo;
        deviceParams.addAll(Map.from(linuxInfo.data));
      } else if (PlatformU.isWindows) {
        final windowsInfo = await DeviceInfoPlugin().windowsInfo;
        deviceParams
            .addAll(Map.from(windowsInfo.data)..remove('digitalProductId'));
      } else if (PlatformU.isWeb) {
        final webInfo = await DeviceInfoPlugin().webBrowserInfo;
        deviceParams.addAll(Map.from(webInfo.data));
      } else {
        deviceParams['operatingSystem'] = PlatformU.operatingSystem;
        deviceParams['operatingSystemVersion'] =
            PlatformU.operatingSystemVersion;
      }
    } catch (e, s) {
      logger.e('failed to load device info', e, s);
      deviceParams['failed'] = e.toString();
    }
  }

  /// PackageInfo: appName+version+buildNumber
  ///  - Android: support
  ///  - for iOS/macOS:
  ///   - if CF** keys not defined in info.plist, return null
  ///   - if buildNumber not defined, return version instead
  ///  - Windows: Not Support
  static Future<void> _loadApplicationInfo() async {
    ///Only android, iOS and macOS are implemented
    _packageInfo =
        await PackageInfo.fromPlatform().catchError((e) => PackageInfo(
              appName: kAppName,
              packageName: kPackageName,
              version: '0.0.0',
              buildNumber: '0',
              buildSignature: '',
            ));
    _packageInfo = PackageInfo(
      appName: _packageInfo!.appName.toTitle(),
      packageName: _packageInfo!.packageName,
      version: _packageInfo!.version,
      buildNumber: _packageInfo!.buildNumber,
    );
    appParams["version"] = _packageInfo?.version;
    appParams["appName"] = _packageInfo?.appName;
    appParams["buildNumber"] = _packageInfo?.buildNumber;
    appParams["packageName"] = _packageInfo?.packageName;
    appParams["commitHash"] = kCommitHash;
    appParams["commitTimestamp"] = commitDate;
    logger.i('Resolved app version: ${_packageInfo?.packageName}'
        ' ${_packageInfo?.version}+${_packageInfo?.buildNumber} $kCommitHash - $commitDate');
  }

  static Future<void> _loadUniqueId(String appPath) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String? originId;
    if (PlatformU.isWeb) {
      // // use generated uuid
      // originId = null;
      // _uuid = '00000000-0000-0000-0000-000000000000';
      // return;
    } else if (PlatformU.isAndroid) {
      originId = await const AndroidId().getId();
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
      originId = (await DeviceInfoPlugin().macOsInfo).systemGUID;
    } else if (PlatformU.isLinux) {
      //cat /etc/machine-id
      final result = await Process.run(
        'cat',
        ['/etc/machine-id'],
        runInShell: true,
      );
      String resultString = result.stdout.toString().trim();
      print('Linux machine id query:\n$resultString');
      originId = resultString;
    } else {
      throw UnimplementedError(PlatformU.operatingSystem);
    }
    if (originId?.isNotEmpty != true) {
      var uuidFile = FilePlus(pathlib.join(appPath, '.uuid'));
      if (uuidFile.existsSync()) {
        originId = await uuidFile.readAsString();
      }
      if (originId?.isNotEmpty != true) {
        originId = const Uuid().v4();
        await uuidFile.writeAsString(originId);
      }
    }
    _uuid = const Uuid().v5(Uuid.NAMESPACE_URL, originId!).toUpperCase();
    _debugOn = FilePlus(joinPaths(appPath, '.debug')).existsSync();
    logger.i('Unique ID: $_uuid');
  }

  static void initiateForTest() {
    _uuid = '00000000-0000-0000-0000-000000000000';
    _packageInfo = PackageInfo(
      appName: kAppName,
      packageName: kPackageName,
      version: '9.9.9',
      buildNumber: '9999',
    );
  }

  static Future<void> resolve(String appPath) async {
    await _loadUniqueId(appPath);
    await _loadDeviceInfo();
    await _loadApplicationInfo();
    _checkMacAppType();
  }

  static void _checkMacAppType() {
    if (!PlatformU.isMacOS) {
      _macAppType = MacAppType.notMacApp;
    } else {
      final String executable = PlatformU.resolvedExecutable;
      final String fpStore = pathlib.absolute(
          pathlib.dirname(executable), '../_MASReceipt/receipt');
      final String fpNotarized =
          pathlib.absolute(pathlib.dirname(executable), '../CodeResources');
      if (FilePlus(fpStore).existsSync()) {
        _macAppType = MacAppType.store;
      } else if (FilePlus(fpNotarized).existsSync()) {
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

  static AppVersion get version => AppVersion.tryParse(fullVersion)!;

  static const String commitHash = kCommitHash;

  static const int commitTimestamp = kCommitTimestamp;

  static String get commitDate => DateFormat.yMd()
      .format(DateTime.fromMillisecondsSinceEpoch(commitTimestamp * 1000));

  static String get commitUrl => "$kProjectHomepage/commit/$commitHash";

  /// e.g. "1.2.3"
  static String get versionString => _packageInfo?.version ?? '';

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

  static int? get androidSdk => _androidSdk;

  /// e.g. "1.2.3+4"
  static String get fullVersion {
    String s = '';
    s += versionString;
    if (buildNumber > 0) s += '+$buildNumber';
    return s;
  }

  /// e.g. "1.2.3 (4)"
  static String get fullVersion2 {
    StringBuffer buffer = StringBuffer(versionString);
    if (buildNumber > 0) {
      buffer.write(' ($buildNumber)');
    }
    return buffer.toString();
  }

  static String get uuid => _uuid!;

  static bool get isDebugDevice {
    const excludeIds = [
      'FB26CA34-0B8F-588C-8542-4A748BB67740', // android
      'C150DF56-B65C-5167-852B-102D487D7159', // ios
      'BC87303D-6010-5DCE-90FB-68E8758EC260', // ios release
      '1D6D5558-9929-5AB0-9CE7-BC2E188948CD', // macos
      '6986A299-F7CB-5BBF-9680-14ED34013C07', // windows
    ];
    return excludeIds.contains(AppInfo.uuid) || _debugOn;
  }

  static bool get isIPad => _isIPad;

  static MacAppType get macAppType => _macAppType;

  static bool get isMacStoreApp => _macAppType == MacAppType.store;

  static bool get isFDroid =>
      PlatformU.isAndroid && packageName == kPackageNameFDroid;
}

enum MacAppType {
  unknown,
  store,
  notarized,
  debug,
  notMacApp,
}
