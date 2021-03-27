import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show min;

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:json_patch/json_patch.dart';
import 'package:share/share.dart';

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
                      db.notifyDbUpdate(true);
                      EasyLoading.showToast(S.of(context).userdata_cleared);
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title: Text(S.of(context).backup),
                onTap: backupUserData,
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
              // ListTile(
              //   title: Text(S.of(context).download_latest_gamedata),
              //   subtitle: Text('为确保兼容性，更新前请升级至最新版APP'),
              //   onTap: downloadGamedata,
              // ),
              ListTile(
                title: Text(S.of(context).reload_default_gamedata),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text(S.of(context).reload_default_gamedata),
                    onTapOk: () async {
                      EasyLoading.show(status: 'reloading');
                      await db.loadZipAssets(kDatasetAssetKey);
                      if (db.loadGameData()) {
                        EasyLoading.showSuccess(
                            S.of(context).reload_data_success);
                      } else {
                        EasyLoading.showError('Failed');
                      }
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
            ],
          ),
        ],
      ),
    );
  }

  /// server not supported yet
  void patchVersion(String version) async {
    Dio _dio = Dio(BaseOptions(baseUrl: db.userData.serverRoot ?? kServerRoot));
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
      db.notifyDbUpdate(true);
    } on FileSelectionCanceledError {} catch (e) {
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future<void> importGamedata() async {
    try {
      // final result = await FilePicker.platform.pickFiles();
      final result = await FilePickerCross.importFromStorage(
          type: FileTypeCross.custom, fileExtension: 'zip,json');
      final file = File(result.path);
      if (file.path.toLowerCase().endsWith('.zip')) {
        EasyLoading.show(status: 'loading');
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
      EasyLoading.showSuccess(S.of(context).import_data_success);
    } on FileSelectionCanceledError {} catch (e) {
      EasyLoading.dismiss();
      showInformDialog(context,
          title: 'Import gamedata failed!', content: e.toString());
    }
  }

  Future backupUserData() async {
    List<String> backupPaths = [
      Platform.isIOS ? S.of(context).ios_app_path + '/user' : db.paths.userDir
    ];
    if (db.paths.userDataExternalBackup != null) {
      backupPaths.add(db.paths.userDataExternalBackup!);
    }
    return SimpleCancelOkDialog(
      title: Text(S.of(context).backup),
      content: Text(backupPaths.join('\n\n')),
      onTapOk: () async {
        final fp = db.backupUserdata();
        showInformDialog(
          context,
          title: S.of(context).backup,
          content: '''临时备份已保存在：\n$fp\n删除应用将可能导致临时备份被删除，强烈建议备份到外部可靠储存位置！''',
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
          ],
        );
      },
    ).show(context);
  }

  Future<void> clearCache() async {
    db.prefs.instance.clear();
    await DefaultCacheManager().emptyCache();
    Directory(db.paths.tempDir)
      ..deleteSync(recursive: true)
      ..createSync(recursive: true);
    imageCache?.clear();
    EasyLoading.showToast(S.current.clear_cache_finish);
  }
}
