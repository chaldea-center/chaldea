import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:rfc_6902/rfc_6902.dart' as jsonpatch;
import 'package:url_launcher/url_launcher.dart';

class AutoUpdateUtil {
  static Dio get _dio => HttpUtils.defaultDio;

  static BuildContext get context => kAppKey.currentContext!;

  /// download dataset-text.zip and unzip it to reload
  static Future<void> autoUpdateDataset() async {
    GitRelease? release;

    final git = GitTool.fromDb();
    try {
      final String baseFolder = join(db.paths.tempDir, 'dataset');
      if (!db.hasNetwork) return;
      release = await git.latestDatasetRelease(testRelease: (_) => true);
      final url = release?.targetAsset?.browserDownloadUrl;
      if (url == null) {
        logger.d('no dataset update found');
        return;
      }
      String v = release!.name.split('-').first;
      if (v.compareTo(db.gameData.version) <= 0) {
        logger.i('ignore dataset $v, cur=${db.gameData.version}');
        return;
      }
      String zipFp = join(
          join(baseFolder, '${release.name}-${release.targetAsset!.name}'));
      if (!File(zipFp).existsSync()) {
        await _dio.download(url, zipFp);
        logger.d('downloaded $zipFp');
      }
      String extractFolder = join(baseFolder, basenameWithoutExtension(zipFp));
      if (extractFolder == zipFp) extractFolder += '.extract';
      _deleteFileOrDir(extractFolder);
      await db.extractZip(fp: zipFp, savePath: extractFolder);
      String datasetFp = join(extractFolder, 'dataset.json');
      if (!File(datasetFp).existsSync()) {
        logger.e('cannot found dataset.json after unzip');
        return;
      }
      final gameData = GameData.fromJson(
          Map.from(jsonDecode(File(datasetFp).readAsStringSync())));
      if (gameData.version.compareTo(db.gameData.version) > 0) {
        await alertReload();
        String previousVer = db.gameData.version;
        String bak = db.paths.gameDataPath + '.bak';
        _deleteFileOrDir(bak);
        File(db.paths.gameDataPath).renameSync(bak);
        File(datasetFp).renameSync(db.paths.gameDataPath);
        if (db.loadGameData()) {
          logger
              .i('update dataset from $previousVer to ${db.gameData.version}');
          EasyLoading.showToast(
              'update dataset from $previousVer to ${db.gameData.version}');
        } else {
          throw 'Load GameData failed, maybe incompatible with current app version';
        }
      } else {
        logger.w('version mismatch release name: ${release.name},'
            ' real version: ${gameData.version}');
      }
    } catch (e, s) {
      logger.e('error update dataset', e, s);
    }
  }

  /// get json patch from server
  static Future<void> patchGameData(
      {bool background = true, void onError(e, s)?}) async {
    String _dataVersion(String releaseName) {
      return releaseName.split('-').first;
    }

    void _reportResult(dynamic e, [StackTrace? s]) {
      logger.e('fail to patch: $e', null, s);
      if (onError != null) onError(e, s);
    }

    if (!background)
      EasyLoading.show(status: 'patching', maskType: EasyLoadingMaskType.clear);
    try {
      if (!db.hasNetwork) {
        _reportResult(S.current.error_no_network);
        return;
      }
      final git = GitTool(GitSource.server);
      final releases = await git.datasetReleases;

      final latestRelease = await git.latestDatasetRelease(releases: releases);
      if (latestRelease == null) {
        _reportResult(S.current.patch_gamedata_error_no_compatible);
        return;
      }
      int newer =
          db.gameData.version.compareTo(_dataVersion(latestRelease.name));
      if (newer >= 0) {
        _reportResult(S.current.update_already_latest);
        return;
      }
      final curRelease = releases.firstWhereOrNull(
          (release) => _dataVersion(release.name) == db.gameData.version);
      if (curRelease == null) {
        print('cur version not found in server: ${db.gameData.version}');
        _reportResult(S.current.patch_gamedata_error_unknown_version);
        AutoUpdateUtil.autoUpdateDataset();
        return;
      }

      final resp = ChaldeaResponse.fromResponse(await db.serverDio
          .get('/patchDataset', queryParameters: {
        'from': curRelease.tagName,
        'to': latestRelease.tagName
      }));
      EasyLoading.dismiss();

      if (resp.success) {
        final patchJson = jsonDecode(resp.body);
        final curData =
            jsonDecode(File(db.paths.gameDataPath).readAsStringSync());
        dynamic newData = jsonpatch.JsonPatch(patchJson).applyTo(curData);
        // encode then decode to verify validation
        final gameData = GameData.fromJson(jsonDecode(jsonEncode(newData)));
        String previousVersion = db.gameData.version;
        if (gameData.version.compareTo(previousVersion) > 0) {
          await alertReload(pop: !background);
          if (db.loadGameData(gameData)) {
            // use patched data, don't use jsonEncode(db.gameData)
            File(db.paths.gameDataPath).writeAsStringSync(jsonEncode(newData));
            logger.i(
                'update dataset from $previousVersion to ${db.gameData.version}');
            EasyLoading.showInfo(
                S.current.patch_gamedata_success_to(db.gameData.version));
          } else {
            throw 'Load GameData failed, maybe incompatible with current app version';
          }
        }
      } else {
        _reportResult(resp.msg);
      }
    } catch (e, s) {
      _reportResult(e, s);
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }

  static Completer? _downloadTask;

  /// background:
  ///   version info->download->alert->install
  /// foreground
  ///   version info->alert->download->alert->install
  static Future<void> checkAppUpdate(
      {bool background = true, bool download = false}) async {
    if (!db.hasNetwork) {
      if (!background) EasyLoading.showError('No network');
      return;
    }
    if (_downloadTask?.isCompleted == false) return null;
    _downloadTask = Completer();
    GitRelease? release;
    Version? version;
    String? releaseNote;
    String? launchUrl; // release page, not download url
    bool upgradable = false;
    if (!background) EasyLoading.show(maskType: EasyLoadingMaskType.clear);

    String? fpInstaller;
    try {
      if (!background) {
        db.prefs.ignoreAppVersion.remove();
      }
      final git = GitTool.fromDb();
      if (Platform.isIOS) {
        // use https and set UA, or the fetched info may be outdated
        // this http request always return iOS version result
        final response = await _dio.get(
            'https://itunes.apple.com/lookup?bundleId=$kPackageName',
            options: Options(responseType: ResponseType.plain, headers: {
              'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
                  " AppleWebKit/537.36 (KHTML, like Gecko)"
                  " Chrome/88.0.4324.146"
                  " Safari/537.36 Edg/88.0.705.62"
            }));
        // print(response.data);
        final jsonData = jsonDecode(response.data.toString().trim());
        // logger.d(jsonData);
        final result = jsonData['results'][0];
        version = Version.tryParse(result['version'] ?? '');
        releaseNote = result['releaseNotes'];
        // no set [release]
      } else {
        release = await git.latestAppRelease();
        version = Version.tryParse(release?.name ?? '');
        releaseNote = release?.body;
        launchUrl = release?.htmlUrl;
        print(version);
      }
      print(release?.targetAsset?.browserDownloadUrl);
      releaseNote = releaseNote?.replaceAll('\r\n', '\n');
      // logger.i('Release note:\n$releaseNote');

      if (Platform.isAndroid && kDebugMode) {
        await Dio(BaseOptions(
                connectTimeout: 3000, headers: HttpUtils.headersWithUA()))
            .get("$kGooglePlayLink&hl=en")
            .then((response) =>
                db.runtimeData.googlePlayAccess = response.statusCode == 200)
            .onError((e, s) {
          return db.runtimeData.googlePlayAccess = false;
        });
      }

      upgradable = version != null && version > AppInfo.versionClass;
      // if (kDebugMode) upgradable = true;
      db.runtimeData.upgradableVersion = upgradable ? version : null;
      String newVersion = version?.version ?? '';

      if (kReleaseMode && (Platform.isIOS || AppInfo.isMacStoreApp)) {
        // Guideline 2.4.5(vii) - Performance
        // The Mac App Store provides customers with notifications of updates
        // pending for all apps delivered through the App Store, and allows the
        // user to update applications through the Mac App Store app. You should
        // not provide additional update checks or updates through your app.
        if (!background) {
          launch(kAppStoreLink);
        }
        return;
      }

      if (!upgradable) {
        logger.i('No update: fetched=${version?.fullVersion}, '
            'cur=${AppInfo.fullVersion2}');
        if (!background) EasyLoading.showInfo(S.current.update_already_latest);
        return;
      }
      if (background && db.prefs.ignoreAppVersion.get() == newVersion) {
        logger.i('Latest version: $version, ignore this update.');
        return;
      }
      if (!background) {
        download = await _showDialog(
                version: version,
                launchUrl: launchUrl,
                releaseNote: releaseNote) ==
            true;
        if (!download) return;
      }
      if (download) {
        fpInstaller = await startDownload(release: release!);
      }

      if (fpInstaller == null) {
        if (!background) EasyLoading.showError('Download Failed');
        return;
      }
      await _showDialog(
          fpInstaller: fpInstaller,
          version: version,
          releaseNote: releaseNote,
          launchUrl: launchUrl);
    } catch (e, s) {
      logger.e('error check app update', e, s);
      if (background) {
        // do nothing
      } else {
        SimpleCancelOkDialog(
          title: Text('Error'),
          content: Text('$e\n$s'),
        ).showDialog(null);
      }
    } finally {
      EasyLoadingUtil.dismiss();
      _downloadTask!.complete();
    }
  }

  static Future<String?> startDownload({required GitRelease release}) async {
    bool validSHA1 = false;
    String? fpInstaller;

    final assetSHA1 = release.targetSHA1Asset;
    print('sha1 file: ${assetSHA1?.name}');
    final String baseDir = join(db.paths.tempDir, 'app');
    String? fpSHA1 = assetSHA1 == null ? null : join(baseDir, assetSHA1.name);
    fpInstaller = join(baseDir, release.targetAsset!.name);

    if (assetSHA1?.browserDownloadUrl != null) {
      print(assetSHA1?.browserDownloadUrl);
      await _dio.download(assetSHA1!.browserDownloadUrl!, fpSHA1);
    }
    String? checksum = fpSHA1 != null && File(fpSHA1).existsSync()
        ? File(fpSHA1).readAsStringSync().trim()
        : null;
    if (checksum?.length != 40) checksum = null;
    // background download should ensure the correct checksum
    if (checksum == null) {
      return null;
    }
    validSHA1 = await _checkSHA1(fpInstaller, checksum, true);
    if (!validSHA1) {
      await _dio.download(release.targetAsset!.browserDownloadUrl!, fpInstaller,
          deleteOnError: true);
      logger.d('downloaded $fpInstaller');
      validSHA1 = await _checkSHA1(fpInstaller, checksum, false);
    } else {
      logger.d('already downloaded $fpInstaller');
    }
    if (validSHA1) return fpInstaller;
  }

  static Future<void> alertReload({bool pop = true}) async {
    await SimpleCancelOkDialog(
      title: Text(S.current.update_dataset),
      content: Text('Ready to reload dataset'),
    ).showDialog(null);
    if (pop)
      Navigator.of(kAppKey.currentContext!).popUntil((route) => route.isFirst);
    await Future.delayed(Duration(milliseconds: 600));
  }

  static Future<bool?> _showDialog({
    required Version version,
    String? fpInstaller,
    String? releaseNote,
    String? launchUrl,
  }) async {
    bool upgradable = version > AppInfo.versionClass;
    EasyLoading.dismiss();
    String content = '';
    if (fpInstaller != null)
      content += LocalizedText.of(
          chs: '安装包已下载\n',
          jpn: 'インストールパッケージがダウンロードされました\n',
          eng: 'Installer is downloaded\n');
    content += S.current.about_update_app_detail(
        AppInfo.fullVersion, version.version, releaseNote ?? '-');
    return SimpleCancelOkDialog(
      title: Text(S.current.about_update_app),
      content: SingleChildScrollView(
        child: Text(content),
      ),
      hideOk: true,
      wrapActionsInRow: true,
      actions: [
        if (upgradable)
          TextButton(
            child: Text(S.current.ignore),
            onPressed: () {
              db.prefs.ignoreAppVersion.set(version.version);
              Navigator.of(context).pop();
            },
          ),
        if (Platform.isAndroid)
          TextButton(
            child: Text('Google Play'),
            onPressed: () {
              launch(kGooglePlayLink);
            },
          ),
        if (Platform.isIOS || Platform.isMacOS)
          TextButton(
            child: Text('App Store'),
            onPressed: () {
              launch(kAppStoreLink);
            },
          ),
        if (Platform.isWindows)
          TextButton(
            child: Text(S.current.release_page),
            onPressed: launchUrl == null ? null : () => launch(launchUrl),
          ),
        if (upgradable && fpInstaller != null)
          TextButton(
            child: Text(S.current.install),
            onPressed: () {
              Navigator.pop(context);
              db.saveUserData();
              _installUpdate(fpInstaller);
              // SimpleCancelOkDialog(
              //   title: Text('Warning'),
              //   content: Text(LocalizedText.of(
              //     chs: '安装包未通过校验，仍然安装？',
              //     jpn: 'インストールパッケージは検証に失敗しましたが、それでもインストールしますか？',
              //     eng:
              //     'The installer failed the checksum verification, still install it?',
              //   )),
              //   onTapOk: () {
              //     _installUpdate(fpInstaller);
              //   },
              // ).showDialog(null);
            },
          ),
        if (upgradable && fpInstaller == null)
          TextButton(
            child: Text(S.current.update),
            onPressed: () async {
              Navigator.pop(context, true);
              await Future.delayed(Duration(milliseconds: 600));
              await EasyLoading.showToast(LocalizedText.of(
                  chs: '后台下载中...',
                  jpn: 'バックグラウンドでダウンロード...',
                  eng: 'Downloading in the background... '));
            },
          ),
      ],
    ).showDialog(null);
  }

  static Future<void> _installUpdate(String fp) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (Platform.isAndroid) {
      final result = await OpenFile.open(fp);
      print('open result: ${result.type}, ${result.message}');
      // await InstallPlugin.installApk(saveFp, AppInfo.packageName);
    } else if (Platform.isMacOS) {
      SimpleCancelOkDialog(
        content: Text(LocalizedText.of(
            chs: '请解压并替换原程序',
            jpn: '元のプログラムを解凍して置き換えてください',
            eng: 'Please unzip and replace the original app')),
        hideCancel: true,
      ).showDialog(kAppKey.currentContext!);
      final result = await OpenFile.open(dirname(fp));
      print('open result: ${result.type}, ${result.message}');
    } else if (Platform.isWindows) {
      String extractFolder = join(dirname(fp), basenameWithoutExtension(fp));
      if (extractFolder == fp) {
        extractFolder = fp + '.extract';
      }
      _deleteFileOrDir(extractFolder);
      await db.extractZip(fp: fp, savePath: extractFolder);
      String? exeFp = Directory(extractFolder)
          .listSync()
          .firstWhereOrNull((element) =>
              FileSystemEntity.isFileSync(element.path) &&
              basename(element.path).toLowerCase() == 'chaldea.exe')
          ?.path;
      if (exeFp == null) {
        throw OSError('file chaldea.exe not found');
      }

      String srcDir = absolute(dirname(exeFp));
      String destDir = absolute(dirname(Platform.resolvedExecutable));
      String backupDir = destDir + '.old';
      _deleteFileOrDir(backupDir);
      Directory(backupDir).createSync(recursive: true);
      String logFp = absolute(join(destDir, 'upgrade.log'));

      String cmdFp = _generateCMD(srcDir, destDir, backupDir, logFp);
      SimpleCancelOkDialog(
        title: Text(S.current.update),
        content: Text('${S.current.restart_to_upgrade_hint}\n'
            '**source**:\n$srcDir\n'
            '**destination**:\n$destDir\n'
            '**backup**:\n$backupDir\n'
            'log:\n$logFp\n'
            'upgrade script:\n$cmdFp'),
        scrollable: true,
        onTapOk: () async {
          db.saveUserData();
          await Future.delayed(Duration(seconds: 1));
          Process.start(cmdFp, ['>>"$logFp"', '2>&1'],
              mode: ProcessStartMode.detached);
        },
      ).showDialog(null);
    }
  }

  static String _generateCMD(
      String srcDir, String destDir, String backupDir, String logFp) {
    if (!File(logFp).existsSync()) File(logFp).createSync(recursive: true);
    StringBuffer buffer = StringBuffer();
    void _writeln(String command) {
      // buffer.writeln('$command >>"$logFp" 2>&1');
      buffer.writeln(command);
    }

    _writeln('echo ready to kill chaldea.exe PID=$pid');
    _writeln('taskkill /F /PID $pid');
    _writeln('echo backup dest "$destDir" to backup "$backupDir"');
    _writeln('xcopy "$destDir" "$backupDir" /E /Y');
    _writeln('echo copy src "$srcDir" to dest "$destDir"');
    _writeln('xcopy "$srcDir" "$destDir" /E /Y');
    _writeln('echo restart chaldea.exe');
    buffer.writeln('"${join(destDir, 'chaldea.exe')}"');
    String cmdFp = absolute(join(db.paths.tempDir, 'upgrade.cmd'));
    File(cmdFp)..writeAsStringSync(buffer.toString());
    return cmdFp;
  }

  static Future<bool> _checkSHA1(String fp, String? checksum,
      [bool deleteOnMismatch = false]) async {
    bool validSHA1 = false;
    var file = File(fp);
    if (checksum == null || !file.existsSync()) {
      validSHA1 = false;
    } else {
      String v = sha1.convert(await file.readAsBytes()).toString();
      validSHA1 = v == checksum;
      logger.d('SHA1 check ${validSHA1 ? 'pass' : 'failed'}:'
          ' "${basename(fp)}"\n $v : $checksum');
      if (!validSHA1 && deleteOnMismatch) {
        logger.d('delete invalid installer: $fp');
        await file.delete();
      }
    }
    return validSHA1;
  }

  static void _deleteFileOrDir(String fp) {
    if (FileSystemEntity.typeSync(fp) != FileSystemEntityType.notFound) {
      File(fp).deleteSync(recursive: true);
    }
  }
}
