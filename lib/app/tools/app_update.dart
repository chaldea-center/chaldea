import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

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

  static Completer<AppUpdateDetail?>? _checkCmpl;
  static Completer<String?>? _downloadCmpl;

  static Future<void> backgroundUpdate() async {
    if (network.unavailable) return;
    final detail = await check();
    if (detail == null) return;
    if (DateTime.now().difference(detail.release.publishedAt).inHours < 2) {
      return;
    }
    if (PlatformU.isAndroid) {
      showUpdateAlert(detail);
      return;
    }
    final savePath = await download(detail);
    final install = await showUpdateAlert(detail);
    if (install == true) installUpdate(detail, savePath);
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

  static Future showUpdateAlert(AppUpdateDetail detail) {
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
          ],
        );
      },
    );
  }

  static Future showInstallAlert(AppVersion version) {
    String body = 'Update downloaded/更新包已下载.';
    if (PlatformU.isWindows || PlatformU.isLinux) {
      body += '\nExtract zip and replace the old version\n请解压并替换旧版本程序文件';
    }
    return showDialog(
      context: kAppKey.currentContext!,
      useRootNavigator: false,
      builder: (context) {
        return SimpleConfirmDialog(
          title: Text('v${version.versionString}'),
          content: Text(body),
          confirmText: S.current.install,
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

  static Future<String?> download(AppUpdateDetail detail) async {
    if (_downloadCmpl != null) return _downloadCmpl!.future;
    if (PlatformU.isAndroid) return null;
    _downloadCmpl = Completer();
    _downloadFileWithCheck(detail)
        .then((value) => _downloadCmpl!.complete(value))
        .catchError((e, s) {
          logger.e('download app release failed', e, s);
          _downloadCmpl!.complete(null);
        })
        .whenComplete(() => _downloadCmpl = null);
    return _downloadCmpl?.future;
  }

  static Future<void> installUpdate(AppUpdateDetail detail, String? fp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (PlatformU.isApple) {
      launch(kAppStoreLink);
    } else if (fp == null || PlatformU.isAndroid) {
      launch(detail.installer.downloadUrl);
      return;
    } else if (PlatformU.isLinux || PlatformU.isWindows) {
      await openFile(dirname(fp));
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
    final checksum = release?.assets.firstWhereOrNull((e) => e.name == 'checksums.txt');
    if (release == null || installer == null) return null;
    if (release.version != null && release.version! <= AppInfo.version) return null;
    AppUpdateDetail? _latest = AppUpdateDetail(release: release, installer: installer, checksums: checksum);
    db.runtimeData.releaseDetail = _latest;
    return _latest;
  }

  static Future<String?> _downloadFileWithCheck(AppUpdateDetail detail) async {
    String? checksum;
    if (detail.checksums != null) {
      String checksums = (await DioE().get(
        detail.checksums!.downloadUrl,
        options: Options(responseType: ResponseType.plain),
      )).data;
      for (final line in const LineSplitter().convert(checksums)) {
        final row = line.split(' ');
        if (row.length >= 2 && row[1] == detail.installer.name) {
          checksum = row[0].toLowerCase();
        }
      }
    }
    String savePath = joinPaths(db.paths.tempDir, 'installer', detail.installer.name);
    final file = File(savePath);
    if (await file.exists() && checksum != null) {
      final localChecksum = sha1.convert(await file.readAsBytes()).toString().toLowerCase();
      if (localChecksum == checksum) return savePath;
    }
    final resp = await DioE().get(detail.installer.downloadUrl, options: Options(responseType: ResponseType.bytes));
    final data = List<int>.from(resp.data);
    if (sha1.convert(data).toString().toLowerCase() == checksum || checksum == null) {
      file.parent.createSync(recursive: true);
      await file.writeAsBytes(data);
      return savePath;
    } else {
      logger.e('checksum mismatch');
    }
    return null;
  }
}

class AppUpdateDetail {
  final _Release release;
  final _Asset installer;
  final _Asset? checksums;

  AppUpdateDetail({required this.release, required this.installer, required this.checksums});
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
  final String browserDownloadUrl;

  late final _Release release;
  _Asset({required this.name, required this.size, required this.browserDownloadUrl});

  String get downloadUrl {
    return db.settings.proxy.worker ? proxyUrl : browserDownloadUrl;
  }

  String get proxyUrl {
    return browserDownloadUrl.replaceFirst('https://github.com/', '${HostsX.worker.cn}/proxy/github/github.com/');
  }

  factory _Asset.fromJson(Map data) {
    return _Asset(name: data['name'], size: data['size'], browserDownloadUrl: data['browser_download_url']);
  }
}
