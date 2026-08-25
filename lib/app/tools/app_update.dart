import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'package:chaldea/app/tools/apk_installer.dart';
import 'package:chaldea/app/tools/desktop_updater.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class AppUpdater {
  const AppUpdater._();

  /// Name of the marker file in the executable folder that toggles the
  /// debug same-version upgrade.
  static const debugUpgradeMarkerFile = 'debug.same_version_upgrade';

  /// Whether a same-version reinstall is allowed to exercise the desktop
  /// upgrade pipeline. Enabled by placing an (empty) file named
  /// [debugUpgradeMarkerFile] next to the executable. File-based (rather
  /// than a source constant or env var) so it can be toggled on a
  /// GUI-launched app by dropping/removing a file, no rebuild needed.
  static bool get debugSameVersionUpgrade {
    if (kIsWeb) return false;

    if (DesktopUpgrader.supported || PlatformU.isAndroid) {
      try {
        final marker = File(p.join(DesktopUpgrader.exeFolder, debugUpgradeMarkerFile));
        if (marker.existsSync()) {
          return true;
        }
      } catch (_) {
        return false;
      }
    }
    if (kDebugMode) return true;
    return false;
  }

  static Completer<AppUpdateDetail?>? _checkCmpl;

  static Future<void> backgroundUpdate() async {
    if (network.unavailable) return;
    final detail = await check();
    if (detail == null) return;
    if (DateTime.now().difference(detail.release.publishedAt).inHours < 2) {
      return;
    }
    if (PlatformU.isAndroid) {
      final install = await showUpdateAlert(detail);
      if (install == true && kAppKey.currentContext != null) {
        await installUpdate(detail);
      }
      return;
    }
    if (DesktopUpgrader.supported) {
      final install = await showUpdateAlert(detail);
      if (install == true && kAppKey.currentContext != null) {
        await showDesktopUpgradeDialog(kAppKey.currentContext!, detail);
      }
      return;
    }
  }

  static Future<void> checkAppStoreUpdate() async {
    // use https and set UA, or the fetched info may be outdated
    // this http request always return iOS version result
    try {
      final response = await Dio().get(
        'https://itunes.apple.com/lookup?bundleId=$kPackageName',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'User-Agent':
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
                " AppleWebKit/537.36 (KHTML, like Gecko)"
                " Chrome/88.0.4324.146"
                " Safari/537.36 Edg/88.0.705.62",
          },
        ),
      );
      // print(response.data);
      final jsonData = jsonDecode(response.data.toString().trim());
      // logger.d(jsonData);
      final result = jsonData['results'][0];
      AppVersion? version = AppVersion.tryParse(result['version'] ?? '');
      if (version != null && version > AppInfo.version) {
        db.runtimeData.upgradableVersion = version;
      }
    } catch (e, s) {
      logger.e('failed to check AppStore update', e, s);
    }
  }

  static Future showUpdateAlert(AppUpdateDetail detail) async {
    // silent manifest-declaration probe (see docs/adr/0003): gates the
    // in-app Install button; never shows a dialog by itself
    final canInstall = PlatformU.isAndroid && await ApkInstaller.isSupported();
    return showDialog(
      context: kAppKey.currentContext!,
      useRootNavigator: false,
      builder: (context) {
        return AlertDialog(
          title: Text('v${detail.release.version?.versionString}'),
          content: Text(detail.release.body),
          scrollable: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(S.current.cancel),
            ),
            TextButton(
              onPressed: () {
                if (PlatformU.isAndroid) {
                  launch(detail.installer.downloadUrl);
                } else {
                  Navigator.pop(context, true);
                }
              },
              child: Text(S.current.update),
            ),
            if (PlatformU.isAndroid)
              TextButton(
                onPressed: () {
                  launch(kGooglePlayLink);
                },
                child: const Text('Google Play'),
              ),
            if (canInstall)
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(S.current.install),
              ),
          ],
        );
      },
    );
  }

  static Future<AppUpdateDetail?> check() async {
    if (_checkCmpl != null) return _checkCmpl!.future;
    _checkCmpl = Completer();
    latestAppRelease()
        .then((value) => _checkCmpl!.complete(value))
        .catchError((e, s) {
          logger.e('check app update failed', e, s);
          _checkCmpl!.complete(null);
        })
        .whenComplete(() => _checkCmpl = null);
    return _checkCmpl?.future;
  }

  /// Store/mobile platforms only — desktop upgrades are handled end-to-end
  /// by [DesktopUpgrader].
  static Future<void> installUpdate(AppUpdateDetail detail) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (PlatformU.isApple) {
      launch(kAppStoreLink);
    } else if (PlatformU.isAndroid && await ApkInstaller.isSupported()) {
      final context = kAppKey.currentContext;
      if (context != null && context.mounted) {
        var filename = detail.installer.name;
        if (!filename.toLowerCase().endsWith('.apk')) filename = '$filename.apk';
        await ApkInstaller.installFromUrl(context, url: detail.installer.downloadUrl, filename: filename);
      }
    } else {
      launch(detail.installer.downloadUrl);
    }
  }

  static Future<AppUpdateDetail?> latestAppRelease() async {
    String? os;
    if (PlatformU.isAndroid) {
      // Google Play limited the REQUEST_INSTALL_PACKAGES permission.
      os = 'android';
    } else if (PlatformU.isWindows) {
      os = 'windows';
    } else if (PlatformU.isLinux) {
      os = 'linux';
    } else if (kDebugMode) {
      os = 'windows';
    }
    if (os == null) return null;
    final release = await _githubLatestRelease('chaldea-center', 'chaldea');
    final installer = release?.assets.firstWhereOrNull((e) => e.name.contains(os!) && !e.name.contains('sha1'));
    if (release == null || installer == null) return null;
    if (release.version != null && release.version! <= AppInfo.version) {
      final allowSameVersion = debugSameVersionUpgrade && release.version == AppInfo.version;
      if (!allowSameVersion) return null;
    }
    AppUpdateDetail? _latest = AppUpdateDetail(release: release, installer: installer);
    db.runtimeData.releaseDetail = _latest;
    return _latest;
  }
}

class AppUpdateDetail {
  final _Release release;
  final _Asset installer;

  AppUpdateDetail({required this.release, required this.installer});
}

Future<_Release?> _githubLatestRelease(String org, String repo) async {
  final dio = DioE();
  final root = db.settings.proxy.worker ? '${HostsX.worker.cn}/proxy/github/api.github.com' : 'https://api.github.com';
  final resp = await dio.get('$root/repos/$org/$repo/releases/latest');
  return _Release.fromJson(resp.data);
}

class _Release {
  final String name;
  final DateTime publishedAt;
  final String body;
  final bool prerelease;
  final List<_Asset> assets;
  final AppVersion? version;
  _Release({
    required this.name,
    required this.publishedAt,
    required this.body,
    required this.prerelease,
    required this.assets,
  }) : version = AppVersion.tryParse(name) {
    for (var asset in assets) {
      asset.release = this;
    }
  }

  factory _Release.fromJson(Map data) {
    return _Release(
      name: data['name'],
      publishedAt: DateTime.parse(data['published_at']),
      body: (data['body'] as String).replaceAll('\r\n', '\n'),
      prerelease: data['prerelease'],
      assets: (data['assets'] as List).map((e) => _Asset.fromJson(e)).toList(),
    );
  }
}

class _Asset {
  final String name;
  final int size;
  final String digest; // sha256:xxx
  final String browserDownloadUrl;

  late final _Release release;
  _Asset({required this.name, required this.size, required this.digest, required this.browserDownloadUrl});

  String get downloadUrl => urls.first;

  String get _proxyUrlGlobal =>
      browserDownloadUrl.replaceFirst('https://github.com/', '${HostsX.worker.global}/proxy/github/github.com/');
  String get _proxyUrlCN =>
      browserDownloadUrl.replaceFirst('https://github.com/', '${HostsX.worker.cn}/proxy/github/github.com/');

  String get proxyUrl {
    return db.settings.proxy.worker ? _proxyUrlCN : _proxyUrlGlobal;
  }

  Set<String> get urls {
    if (db.settings.proxy.worker) {
      return {_proxyUrlCN, _proxyUrlGlobal};
    }
    return {browserDownloadUrl, _proxyUrlGlobal, _proxyUrlCN};
  }

  factory _Asset.fromJson(Map data) {
    return _Asset(
      name: data['name'],
      size: data['size'],
      digest: data['digest'],
      browserDownloadUrl: data['browser_download_url'],
    );
  }
}
