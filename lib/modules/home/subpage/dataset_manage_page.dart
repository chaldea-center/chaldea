import 'dart:convert';
import 'dart:io';
import 'dart:math' show min;

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:json_patch/json_patch.dart';
import 'package:path/path.dart' show basename;

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
    updateCachedDataFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Dataset version control'),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: 'Userdata',
            children: <Widget>[
              ListTile(
                title: Text('Clear userdata'),
                onTap: () {
                  showDialog(
                      context: context,
                      child: SimpleCancelOkDialog(
                        title: Text('Confirm to delete userdata?'),
                        onTapOk: () async {
                          Fluttertoast.showToast(msg: 'cleaning userdata...');
                          await db.clearData(user: true, game: false);
                          setState(() {});
                          Fluttertoast.showToast(msg: 'userdata cleared.');
                        },
                      ));
                },
              ),
            ],
          ),
          TileGroup(
            header: 'GameData',
            children: <Widget>[
              ListTile(
                title: Text('Current Version'),
                trailing: Text(db.gameData.version),
              ),
              ListTile(
                title: Text('Reload default gamedata'),
                onTap: () {
                  showDialog(
                      context: context,
                      child: SimpleCancelOkDialog(
                        title: Text('Confirm to reload gamedata?'),
                        onTapOk: () async {
                          Fluttertoast.showToast(
                              msg: 'reloading gamedata...',
                              toastLength: Toast.LENGTH_LONG);
                          await db.loadZipAssets(kDefaultDatasetAssetKey,
                              force: true);
                          if (await db.loadGameData()) {
                            Fluttertoast.showToast(msg: 'gamedata reloaded.');
                          }
                          setState(() {});
                        },
                      ));
                },
              ),
              ListTile(
                title: Text('Download icons'),
                onTap: () {
                  db.gameData.icons.forEach((name, icon) async {
                    final filepath = join(db.paths.gameIconDir, icon.filename);
                    if (!File(filepath).existsSync()) {
                      try {
                        Response response = await _dio.download(icon.url,
                            join(db.paths.gameIconDir, icon.filename));
                        if (response.statusCode != 200) {
                          print('error $name, response: $response');
                          Fluttertoast.showToast(msg: '$name download failed');
                        } else {
                          print('downloaded icon $name');
                        }
                      } catch (e) {
                        print('download icon $name error: $e');
                        Fluttertoast.showToast(msg: '$name download failed');
                      }
                    }
                  });
                },
              ),
              ListTile(
                title: Text('Clear and reload default data'),
                subtitle: Text('including icons'),
                onTap: () {
                  showDialog(
                      context: context,
                      child: SimpleCancelOkDialog(
                        title: Text('Confirm to clear and reload?'),
                        onTapOk: () async {
                          Fluttertoast.showToast(
                              msg: 'clear & reloading',
                              toastLength: Toast.LENGTH_LONG);
                          await db.clearData(game: true);
                          setState(() {});
                          Fluttertoast.showToast(
                              msg: 'Default dataset loaded.');
                        },
                      ));
                },
              )
            ],
          ),
          TileGroup(
            header: '已下载',
            children: cachedFiles.isEmpty
                ? [ListTile(title: Text('No cached datasets'))]
                : <Widget>[
                    for (var filename in cachedFiles.keys)
                      ListTile(
                        title: Text(filename),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 'delete',
                                child: Text(S.of(context).delete)),
                            PopupMenuItem(
                                value: 'extract', child: Text('Extract'))
                          ],
                          onSelected: (v) async {
                            switch (v) {
                              case 'delete':
                                File(cachedFiles[filename]).deleteSync();
                                setState(() {
                                  updateCachedDataFile();
                                });
                                Fluttertoast.showToast(
                                    msg: '$filename deleted.');
                                break;
                              case 'extract':
                                await db.extractZip(
                                    File(cachedFiles[filename])
                                        .readAsBytesSync()
                                        .cast<int>(),
                                    db.paths.gameDataDir);
                                await db.loadGameData();
                                setState(() {});
                                Fluttertoast.showToast(
                                    msg: '$filename extracted.');
                                break;
                            }
                          },
                        ),
                      )
                  ],
          ),
          TileGroup(
            header: 'Online Versions',
            children: <Widget>[
              ListTile(
                title: Text('Server'),
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
                title: Center(child: Text('Check Online Versions')),
                onTap: checkOnlineVersions,
              ),
              for (var version in onlineVersions)
                ListTile(
                  title: Text(version),
                  trailing: Wrap(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.file_download),
                          tooltip: 'Full',
                          onPressed: () {
                            downloadVersion(version);
                          }),
                      IconButton(
                          icon: Icon(Icons.library_add),
                          tooltip: 'Patch',
                          onPressed: () {
                            patchVersion(version);
                          })
                    ],
                  ),
                )
            ],
          )
        ],
      ),
    );
  }

  void updateCachedDataFile() {
    cachedFiles.clear();
    Directory(db.paths.datasetCacheDir)
        .listSync(followLinks: false)
        .forEach((entry) {
      if (entry.path.toLowerCase().endsWith('.zip')) {
        cachedFiles[basename(entry.path)] = entry.path;
      }
    });
  }

  void checkOnlineVersions() async {
    try {
      Response response = await _dio.get('/check_versions');
      if (response.statusCode == 200) {
        print('receive data: ${response.data}.');
        setState(() {
          onlineVersions = List.castFrom(response.data);
          onlineVersions.sort();
          onlineVersions = onlineVersions.reversed.toList();
        });
        Fluttertoast.showToast(msg: 'Online version list loaded');
      } else {
        Fluttertoast.showToast(msg: 'server error: ${response.statusCode}');
        print('---error, response---\n$response\n----------');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'check online versions failed.');
      print('check online versions error:\n$e');
    }
  }

  void downloadVersion(String version) async {
    try {
      Response response = await _dio.get('/download',
          queryParameters: {'version': version},
          options: Options(responseType: ResponseType.bytes));
      print(response.headers);
      if (response.statusCode == 200) {
        File file =
            File(join(db.paths.datasetCacheDir, 'dataset-$version.zip'));
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        raf.closeSync();
        setState(() {
          updateCachedDataFile();
        });
        Fluttertoast.showToast(msg: 'Version $version downloaded');
      }
    } catch (e) {
      print('error download:\n$e');
      Fluttertoast.showToast(msg: 'error download: $e');
      rethrow;
    }
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
        await db.loadGameData();
        setState(() {});
        Fluttertoast.showToast(msg: 'patch success.');
        print('patched version: ${patched['version']}');
      }
    } catch (e, s) {
      Fluttertoast.showToast(msg: 'patch data failed.');
      print('patch data error:\n$e');
      print('stack trace: \n$s');
      rethrow;
    }
  }
}
