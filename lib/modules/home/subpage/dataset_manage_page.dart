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

  Dio _dio = Dio(BaseOptions(baseUrl: db.userData.serverDomain));

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
                      db.onAppUpdate();
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
                        : db.paths.userDataDir),
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
                                    [db.paths.userDataDir],
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
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.people),
                          title: Text(S.of(context).userdata),
                          onTap: importUserData,
                        ),
                        ListTile(
                          leading: Icon(Icons.people),
                          title: Text(S.of(context).guda_servant_data),
                          onTap: () => importGudaData(false),
                        ),
                        ListTile(
                          leading: Icon(Icons.category),
                          title: Text(S.of(context).guda_item_data),
                          onTap: () => importGudaData(true),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(S.of(context).reset_svt_enhance_state),
                subtitle: Text(S.of(context).reset_svt_enhance_state_hint),
                onTap: () {
                  db.curUser.servants.forEach((svtNo, svt) {
                    svt.tdIndex = 0;
                    svt.skillIndex.fillRange(0, svt.skillIndex.length, null);
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
                      await db.loadZipAssets(kDatasetAssetKey, force: true);
                      canceler();
                      if (db.loadGameData()) {
                        EasyLoading.showToast(
                            S.of(context).reload_data_success);
                      }
                      db.onAppUpdate();
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
                        db.onAppUpdate();
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

  void patchVersion(String version) async {
    try {
      Response response = await _dio.get('/patch',
          queryParameters: {'from': db.gameData.version, 'to': version});
      if (response.statusCode == 200) {
        var patch = response.data;
        print(
            'download patch: ${patch.toString().substring(0, min(200, patch.toString().length))}');
        final patched = JsonPatch.apply(
            db.getJsonFromFile(db.paths.gameDataFilepath),
            List.castFrom(patch));
        File file = File(db.paths.gameDataFilepath);
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
    Navigator.of(context).pop();
    try {
      FilePickerCross result = await FilePickerCross.importFromStorage(
          type: FileTypeCross.custom, fileExtension: 'json');
      final path = result.path;
      db.userData =
          UserData.fromJson(json.decode(File(path).readAsStringSync()));
      EasyLoading.showToast('${S.current.import_data_success}:\n$path');
      db.saveUserData();
    } on FileSelectionCanceledError {} catch (e) {
      EasyLoading.showToast(S.of(context).import_data_error(e));
    }
  }

  void importGudaData(bool isItem) {
    // pop bottom sheet first
    Navigator.of(context).pop();

    Future<List<List<String>>> _parseGudaData() async {
      FilePickerCross filePickerCross =
          await FilePickerCross.importFromStorage();
      final content = File(filePickerCross.path).readAsStringSync();
      List<String> lines = content.trim().split(';');
      final mat = lines.map((e) => e.trim().split('/'));
      return mat.where((e) => e.isNotEmpty).toList();
    }

    void updateGudaItems(List<List<String>> gudaData) {
      final replaceKeys = {
        "万死之毒针": "万死的毒针",
        "震荡火药": "振荡火药",
        "閑古鈴": "闲古铃",
        "禍罪の矢尻": "祸罪之箭头",
        "暁光炉心": "晓光炉心",
        "九十九鏡": "九十九镜",
        "真理の卵": "真理之卵"
      };
      for (var row in gudaData) {
        if (row.isEmpty) continue;
        String itemKey = row[1], itemNum = row[2];
        itemKey = itemKey.replaceAll('金棋', '金像');
        if (replaceKeys.containsKey(itemKey)) {
          itemKey = replaceKeys[itemKey];
        }
        if (db.gameData.items.keys.contains(itemKey)) {
          db.curUser.items[itemKey] = int.parse(itemNum);
        } else {
          print('Item $itemKey not found');
        }
      }
      EasyLoading.showToast(S.of(context).import_data_success);
      print(db.curUser.items);
      db.saveUserData();
    }

    void updateGudaSevants(List<List<String>> gudaData) {
      //            0 1  2 3  4 5 6 7  8  9
      // 0  1   2   3 4  5 6  7 8 9 10 11 12
      // 3/name/0  /1/4/ 4/10/2/5/4/9/ 85/92;
      final lvs = [60, 65, 70, 75, 80, 85, 90, 92, 94, 96, 98, 100];
      final startLvs = [65, 60, 65, 70, 80, 90];

      for (var row in gudaData) {
        int svtNo = int.parse(row[0]);
        final svt = db.gameData.servants[svtNo];
        List<int> values =
            List.generate(10, (index) => int.parse(row[index + 3]));
        ServantPlan cur = ServantPlan(favorite: true),
            target = ServantPlan(favorite: true);
        cur
          ..ascension = values[0]
          ..skills = [values[2], values[4], values[6]]
          ..dress = List.generate(svt.itemCost.dressName.length, (_) => 0);
        target
          ..ascension = values[1]
          ..skills = [values[3], values[5], values[7]]
          ..dress = List.generate(svt.itemCost.dressName.length, (_) => 0);
        int rarity = db.gameData.servants[svtNo].info.rarity;
        int startIndex = lvs.indexOf(startLvs[rarity]);
        cur.grail = lvs.indexOf(values[8]) - startIndex;
        target.grail = lvs.indexOf(values[9]) - startIndex;
        db.curUser.servants[svtNo] = ServantStatus(curVal: cur);
        db.curUser.curSvtPlan[svtNo] = target;
      }
      EasyLoading.showToast(S.of(context).import_data_success);
      db.saveUserData();
    }

    showInformDialog(
      context,
      title: isItem
          ? S.of(context).import_guda_items
          : S.of(context).import_guda_servants,
      content: S.of(context).import_guda_hint,
      showOk: false,
      showCancel: true,
      actions: [
        TextButton(
            onPressed: () async {
              try {
                final gudaData = await _parseGudaData();
                if (isItem) {
                  updateGudaItems(gudaData);
                } else {
                  updateGudaSevants(gudaData);
                }
                Navigator.of(context).pop();
              } on FileSelectionCanceledError {
                // EasyLoading.showToast('cancelled');
              } catch (e) {
                EasyLoading.showToast('Import failed! Error:\n$e');
              }
            },
            child: Text(S.of(context).update)),
        TextButton(
            onPressed: () async {
              try {
                final gudaData = await _parseGudaData();
                if (isItem) {
                  db.curUser.items.clear();
                  updateGudaItems(gudaData);
                } else {
                  db.curUser.servants.clear();
                  db.curUser.servants.clear();
                  updateGudaSevants(gudaData);
                }
                Navigator.of(context).pop();
              } on FileSelectionCanceledError {
                // EasyLoading.showToast('cancelled');
              } catch (e) {
                EasyLoading.showToast('Import failed! Error:\n$e');
              }
            },
            child: Text(S.of(context).overwrite)),
      ],
    );
  }

  Future<void> importGamedata() async {
    VoidCallback canceler;
    try {
      // final result = await FilePicker.platform.pickFiles();
      final result = await FilePickerCross.importFromStorage(
          type: FileTypeCross.custom, fileExtension: 'zip,json');
      final file = File(result.path);
      if (file.path.toLowerCase().endsWith('.zip')) {
        canceler = showMyProgress(status: 'loading');
        await db.extractZip(
          file.readAsBytesSync().cast<int>(),
          db.paths.gameDataDir,
        );
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
      final gitTool = GitTool.fromIndex(db.userData.appDatasetUpdateSource);
      final release = await gitTool.latestDatasetRelease(fullSize);
      Navigator.of(context).pop();
      String fp = pathlib.join(
          db.paths.tempPath, '${release?.name}-${release?.targetAsset?.name}');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadDialog(
          url: release?.targetAsset?.browserDownloadUrl ?? '',
          savePath: fp,
          onComplete: () async {
            var canceler = showMyProgress(status: 'loading');
            try {
              await db.extractZip(
                File(fp).readAsBytesSync().cast<int>(),
                db.paths.gameDataDir,
              );
              db.loadGameData();
              Navigator.of(context).pop();
              EasyLoading.showToast(S.of(context).import_data_success);
            } catch (e) {
              EasyLoading.showToast(S.of(context).import_data_error(e));
            } finally {
              canceler();
            }
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
                launch(GitTool.getReleasePageUrl(
                    db.userData.appDatasetUpdateSource, false));
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
    EasyLoading.showToast(S.current.clear_cache_finish);
  }
}
