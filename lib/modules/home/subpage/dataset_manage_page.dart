import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show min;

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:json_patch/json_patch.dart';
import 'package:path/path.dart' as pathlib;
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DatasetManagePage extends StatefulWidget {
  @override
  _DatasetManagePageState createState() => _DatasetManagePageState();
}

class _DatasetManagePageState extends State<DatasetManagePage> {
  Map<String, String> cachedFiles = {};
  List<String> onlineVersions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.of(context).dataset_management),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: S.of(context).userdata,
            footer: S.of(context).settings_userdata_footer,
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).clear),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text(S.of(context).clear_userdata),
                    onTapOk: () async {
                      await db.clearData(user: true, game: false);
                      db.notifyAppUpdate();
                      EasyLoading.showToast(S.of(context).userdata_cleared);
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title: Text(S.of(context).backup),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text(S.of(context).backup),
                    content: Text(Platform.isIOS
                        ? S.of(context).ios_app_path + '/user'
                        : db.paths.userDir),
                    onTapOk: () async {
                      final fp = db.backupUserdata();
                      showInformDialog(context,
                          title: S.of(context).backup_success,
                          content: fp,
                          actions: [
                            if (Platform.isAndroid || Platform.isIOS)
                              TextButton(
                                child: Text(S.of(context).share),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Share.shareFiles([fp]);
                                },
                              ),
                            if (Platform.isMacOS || Platform.isWindows)
                              TextButton(
                                child: Text(S.of(context).open),
                                onPressed: () {
                                  Process.run(
                                    Platform.isMacOS ? 'open' : 'start',
                                    [db.paths.userDir],
                                    runInShell: true,
                                  );
                                },
                              ),
                          ]);
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title: Text(S.of(context).import_data),
                onTap: importUserData,
              ),
              ListTile(
                title: Text(S.of(context).reset_svt_enhance_state),
                subtitle: Text(S.of(context).reset_svt_enhance_state_hint),
                onTap: () {
                  db.curUser.servants.forEach((svtNo, svtStatus) {
                    svtStatus.resetEnhancement();
                  });
                  db.saveUserData();
                  EasyLoading.showToast(S.of(context).reset_success);
                },
              )
            ],
          ),
          TileGroup(
            header: S.of(context).gamedata,
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).version),
                trailing: Text(db.gameData.version),
              ),
              ListTile(
                title: Text(S.of(context).download_latest_gamedata),
                subtitle: Text('为确保兼容性，更新前请升级至最新版APP'),
                onTap: downloadGamedata,
              ),
              ListTile(
                title: Text(S.of(context).reload_default_gamedata),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text(S.of(context).reload_default_gamedata),
                    onTapOk: () async {
                      var canceler = showMyProgress(status: 'reloading');
                      await db.loadZipAssets(kDatasetAssetKey);
                      canceler();
                      if (db.loadGameData()) {
                        EasyLoading.showToast(
                            S.of(context).reload_data_success);
                      }
                      db.notifyAppUpdate();
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title:
                    Text('${S.of(context).import_data} (dataset*.zip/.json)'),
                onTap: importGamedata,
              ),
              ListTile(
                title: Text(S.of(context).clear_cache),
                subtitle: Text(S.of(context).clear_cache_hint),
                onTap: clearCache,
              ),
              ListTile(
                title: Text(S.of(context).delete_all_data),
                subtitle: Text(S.of(context).delete_all_data_hint),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text(S.of(context).delete_all_data),
                    onTapOk: () async {
                      var canceler = showMyProgress(
                          status: 'loading...',
                          maskType: EasyLoadingMaskType.clear);
                      db.clearData(game: true).then((_) {
                        canceler();
                        db.notifyAppUpdate();
                      });
                    },
                  ).show(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// server not supported yet
  void patchVersion(String version) async {
    Dio _dio = Dio(BaseOptions(baseUrl: db.userData.serverRoot));
    try {
      Response response = await _dio.get('/patch',
          queryParameters: {'from': db.gameData.version, 'to': version});
      if (response.statusCode == 200) {
        var patch = response.data;
        print(
            'download patch: ${patch.toString().substring(0, min(200, patch.toString().length))}');
        final patched = JsonPatch.apply(
            db.getJsonFromFile(db.paths.gameDataPath), List.castFrom(patch));
        File file = File(db.paths.gameDataPath);
        var raf = file.openSync(mode: FileMode.write);
        raf.writeStringSync(json.encode(patched));
        raf.closeSync();
        db.loadGameData();
        setState(() {});
        EasyLoading.showToast('patch success.');
        print('patched version: ${patched['version']}');
      }
    } catch (e, s) {
      EasyLoading.showToast('patch data failed.');
      print('patch data error:\n$e');
      print('stack trace: \n$s');
      rethrow;
    }
  }

  void importUserData() async {
    try {
      FilePickerCross result = await FilePickerCross.importFromStorage(
          type: FileTypeCross.custom, fileExtension: 'json');
      final path = result.path;
      db.userData =
          UserData.fromJson(json.decode(File(path).readAsStringSync()));
      EasyLoading.showToast('${S.current.import_data_success}:\n$path');
      db.saveUserData();
      db.notifyAppUpdate();
    } on FileSelectionCanceledError {} catch (e) {
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future<void> importGamedata() async {
    var canceler;
    try {
      // final result = await FilePicker.platform.pickFiles();
      final result = await FilePickerCross.importFromStorage(
          type: FileTypeCross.custom, fileExtension: 'zip,json');
      final file = File(result.path);
      if (file.path.toLowerCase().endsWith('.zip')) {
        canceler = showMyProgress(status: 'loading');
        await db.extractZip(fp: file.path, savePath: db.paths.gameDir);
        db.loadGameData();
      } else if (file.path.toLowerCase().endsWith('.json')) {
        final newData = GameData.fromJson(jsonDecode(file.readAsStringSync()));
        if (newData.version != '0') {
          db.gameData = newData;
        } else {
          throw FormatException('Invalid json contents');
        }
      } else {
        throw FormatException('unsupported file type');
      }
      showInformDialog(context, title: S.of(context).import_data_success);
    } on FileSelectionCanceledError {} catch (e) {
      showInformDialog(context,
          title: 'Import gamedata failed!', content: e.toString());
    } finally {
      canceler?.call();
    }
  }

  void downloadGamedata() {
    void _downloadAsset([bool fullSize = true]) async {
      final gitTool = GitTool.fromIndex(db.userData.updateSource);
      final release = await gitTool.latestDatasetRelease(fullSize);
      Navigator.of(context).pop();
      String fp = pathlib.join(
          db.paths.tempDir, '${release?.name}-${release?.targetAsset?.name}');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadDialog(
          url: release?.targetAsset?.browserDownloadUrl ?? '',
          savePath: fp,
          notes: release?.body,
          onComplete: () async {
            var canceler = showMyProgress(status: 'loading');
            try {
              await db.extractZip(fp: fp, savePath: db.paths.gameDir);
              db.loadGameData();
              Navigator.of(context).pop();
              canceler();
              EasyLoading.showToast(S.of(context).import_data_success);
            } catch (e) {
              canceler();
              EasyLoading.showToast(S.of(context).import_data_error(e));
            } finally {}
          },
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(S.of(context).dataset_type_entire),
              subtitle: Text(S.of(context).dataset_type_entire_hint),
              onTap: () => _downloadAsset(true),
            ),
            ListTile(
              title: Text(S.of(context).dataset_type_text),
              subtitle: Text(S.of(context).dataset_type_text_hint),
              onTap: () => _downloadAsset(false),
            ),
            ListTile(
              title: Text(S.of(context).dataset_goto_download_page),
              subtitle: Text(S.of(context).dataset_goto_download_page_hint),
              onTap: () {
                launch(
                    GitTool.getReleasePageUrl(db.userData.updateSource, false));
              },
            )
          ],
        );
      },
    );
  }

  Future<void> clearCache() async {
    db.prefs.clear();
    await DefaultCacheManager().emptyCache();
    Directory(db.paths.tempDir)
      ..deleteSync(recursive: true)
      ..createSync(recursive: true);
    imageCache?.clear();
    EasyLoading.showToast(S.current.clear_cache_finish);
  }
}
