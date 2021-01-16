import 'dart:convert';
import 'dart:io';
import 'dart:math' show min;

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:json_patch/json_patch.dart';
import 'package:path/path.dart' as pathlib;
import 'package:share/share.dart';

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
        title: Text('数据管理'),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: '个人数据',
            footer: '更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置',
            children: <Widget>[
              ListTile(
                title: Text('清除'),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Confirm'),
                    content: Text('Delete userdata?'),
                    onTapOk: () async {
                      EasyLoading.showToast('cleaning userdata...');
                      await db.clearData(user: true, game: false);
                      setState(() {});
                      EasyLoading.showToast('userdata cleared.');
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title: Text('备份'),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Confirm'),
                    content: Text('备份到此文件夹:\n${db.paths.userDataDir}'),
                    onTapOk: () async {
                      final fp = db.backupUserdata();
                      showInformDialog(context,
                          title: 'Backup success',
                          content: fp,
                          actions: [
                            if (Platform.isAndroid || Platform.isIOS)
                              FlatButton(
                                child: Text('分享'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Share.shareFiles([fp]);
                                },
                              ),
                          ]);
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title: Text('导入'),
                onTap: () async {
                  try {
                    FilePickerCross result =
                        await FilePickerCross.importFromStorage(
                            type: FileTypeCross.custom, fileExtension: 'json');
                    final path = result.path;
                    db.userData = UserData.fromJson(
                        json.decode(File(path).readAsStringSync()));
                    EasyLoading.showToast(
                        'successfully imported userdata:\n$path');
                    db.saveUserData();
                  } on FileSelectionCanceledError {} catch (e) {
                    EasyLoading.showToast('Import userdata failed! Error:\n$e');
                  }
                },
              ),
              ListTile(
                title: Text('导入Guda数据'),
                onTap: () async {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.people),
                              title: Text('从者数据'),
                              onTap: () => importGudaData(false),
                            ),
                            ListTile(
                              leading: Icon(Icons.category),
                              title: Text('素材数据'),
                              onTap: () => importGudaData(true),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
          TileGroup(
            header: '游戏数据',
            children: <Widget>[
              ListTile(
                title: Text('版本'),
                trailing: Text(db.gameData.version),
              ),
              ListTile(
                title: Text('重新载入预装版本'),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Confirm'),
                    content: Text('reload default dataset?'),
                    onTapOk: () async {
                      EasyLoading.showToast('reloading gamedata...',
                          duration: Duration(seconds: 4));
                      await db.loadZipAssets(kDatasetAssetKey, force: true);
                      if (db.loadGameData()) {
                        EasyLoading.showToast('gamedata reloaded.');
                      }
                      setState(() {});
                    },
                  ).show(context);
                },
              ),
              // TODO: disabled, download all images including illustration
              if (kDebugMode)
                ListTile(
                  title: Text('Download icons'),
                  onTap: () {
                    db.gameData.icons.forEach((name, icon) async {
                      final filepath =
                          pathlib.join(db.paths.gameIconDir, icon.originName);
                      if (!File(filepath).existsSync()) {
                        try {
                          Response response =
                              await _dio.download(icon.url, filepath);
                          if (response.statusCode != 200) {
                            print('error $name, response: $response');
                            EasyLoading.showToast('$name download failed');
                          } else {
                            print('downloaded icon $name');
                          }
                        } catch (e) {
                          print('download icon $name error: $e');
                          EasyLoading.showToast('$name download failed');
                        }
                      }
                    });
                  },
                ),
              ListTile(
                title: Text('删除所有数据'),
                subtitle: Text('包含用户数据、游戏数据、图片资源'),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Confirm'),
                    content: Text('clear then reload default dataset?'),
                    onTapOk: () async {
                      EasyLoading.showToast('clear & reloading',
                          duration: Duration(seconds: 4));
                      await db.clearData(game: true);
                      setState(() {});
                      EasyLoading.showToast('Default dataset loaded.');
                    },
                  ).show(context);
                },
              ),
              ListTile(
                title: Text('导入 (dataset*.zip/.json)'),
                onTap: () async {
                  try {
                    // final result = await FilePicker.platform.pickFiles();
                    final result = await FilePickerCross.importFromStorage(
                        type: FileTypeCross.custom, fileExtension: 'zip,json');
                    final file = File(result.path);
                    if (file.path.toLowerCase().endsWith('.zip')) {
                      EasyLoading.showToast('Loading',
                          maskType: EasyLoadingMaskType.black);
                      db.extractZip(file.readAsBytesSync().cast<int>(),
                          db.paths.gameDataDir);
                      db.loadGameData();
                    } else if (file.path.toLowerCase().endsWith('.json')) {
                      final newData = GameData.fromJson(
                          jsonDecode(file.readAsStringSync()));
                      if (newData.version != '0') {
                        db.gameData = newData;
                      } else {
                        throw FormatException('Invalid json contents');
                      }
                    } else {
                      throw FormatException('unsupported file type');
                    }
                    showInformDialog(context,
                        title: 'Import dataset successfully');
                  } on FileSelectionCanceledError {} catch (e) {
                    showInformDialog(context,
                        title: 'Import gamedata failed!',
                        content: e.toString());
                  }
                },
              ),
            ],
          ),
          TileGroup(
            header: 'Download',
            children: <Widget>[
              ListTile(
                title: Text('服务器(NotImplemented)'),
                subtitle: Text(db.userData.serverDomain ?? 'none'),
                trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => InputCancelOkDialog(
                          title: 'Edit server',
                          text: db.userData.serverDomain,
                          errorText: S.of(context).input_error,
                          onSubmit: (v) {
                            v = v.trim();
                            if (v.endsWith('/')) {
                              v = v.substring(0, v.length - 1);
                            }
                            setState(() {
                              db.userData.serverDomain = v;
                              _dio.options.baseUrl = db.userData.serverDomain;
                            });
                          },
                        ),
                      );
                    }),
              ),
              ListTile(
                title: Center(child: Text('下载资源')),
                onTap: () {
                  EasyLoading.showToast('NotImplemented');
                  // db.downloadGameData();
                  // db.onAppUpdate();
                },
              ),
            ],
          )
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
      EasyLoading.showToast('导入素材数据成功');
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
      EasyLoading.showToast('导入从者数据成功');
      db.saveUserData();
    }

    showInformDialog(
      context,
      title: '导入${isItem ? '素材' : '从者'}数据',
      content: '更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据',
      showOk: false,
      showCancel: true,
      actions: [
        FlatButton(
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
            child: Text('更新')),
        FlatButton(
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
            child: Text('覆盖')),
      ],
    );
  }
}
