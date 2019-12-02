import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' show basename;

class DatasetManagePage extends StatefulWidget {
  @override
  _DatasetManagePageState createState() => _DatasetManagePageState();
}

class _DatasetManagePageState extends State<DatasetManagePage> {
  Map<String, String> cachedFiles = {};
  List<String> onlineVersions = [];
  TextEditingController _editingController;

  Dio _dio = Dio(BaseOptions(baseUrl: db.userData.serverDomain));

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: db.userData.serverDomain);
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
                          await db.clearData(user: true, game: true);
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
                title: Text('Reload current gamedata'),
                onTap: () {
                  showDialog(
                      context: context,
                      child: SimpleCancelOkDialog(
                        title: Text('Confirm to reload gamedata?'),
                        onTapOk: () async {
                          Fluttertoast.showToast(
                              msg: 'reloading gamedata...',
                              toastLength: Toast.LENGTH_LONG);
                          await db.loadGameData();
                          setState(() {});
                          Fluttertoast.showToast(msg: 'gamedata reloaded.');
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
                title: Row(
                  children: <Widget>[
                    Text('Server:   '),
                    Expanded(
                        child: TextField(
                      decoration: InputDecoration(isDense: true),
                      textAlign: TextAlign.center,
                      controller: _editingController,
                      onChanged: (s) {
                        db.userData.serverDomain = s.trim();
                        _dio.options.baseUrl = db.userData.serverDomain;
                      },
                    ))
                  ],
                ),
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
    Response response = await _dio.get('/check_versions');
    if (response.statusCode == 200) {
      try {
        print('receive data: ${response.data}.');
        setState(() {
          onlineVersions = List.castFrom(response.data);
          onlineVersions.sort();
          onlineVersions = onlineVersions.reversed.toList();
        });
        Fluttertoast.showToast(msg: 'Online version list loaded');
      } catch (e) {
        Fluttertoast.showToast(msg: 'parse data failed.');
        print('parse json error:\n$e');
      }
    } else {
      Fluttertoast.showToast(msg: 'server error: ${response.statusCode}');
      print('---response---\n$response\n----------');
    }
  }

  void downloadVersion(String version) async {
    final url = '/download?version=$version';
    try {
      Response response = await _dio.get(url,
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
      print(e);
      Fluttertoast.showToast(msg: 'error download: $e');
      rethrow;
    }
  }

  void patchVersion(String version) async {}
}
