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
                                child: Text('Share'),
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
                title: Text('Reload default gamedata'),
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
                title: Text('Clear and reload all data'),
                subtitle: Text('including icons'),
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
                title: Text('Server(NotImplemented)'),
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
                title: Center(child: Text('Download Data')),
                onTap: () {
                  EasyLoading.showToast('Unimplemented');
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
}
