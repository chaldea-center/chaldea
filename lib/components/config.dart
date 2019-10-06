import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'datatypes/datatypes.dart';

/// app config:
///  - app database
///  - user database
class Database {
  VoidCallback onAppUpdate;
  AppData appData;
  GameData gameData;

  Plans get curPlan=>appData.users[appData.curUserName]?.plans;
  static String _rootPath = '';
  String get rootPath => _rootPath;

  // initialization
  Future<Null> initial() async {
    _rootPath = (await getApplicationDocumentsDirectory()).path;
  }

  // load data
  Future<Null> loadData(
      {bool app = true, bool game = true}) async {
    if (app) {
      appData = parseJson(
          parser: () =>
              AppData.fromJson(getJsonFromFile(appDataFilename, k: {})),
          k: () => AppData());
      print('appdata reloaded');
    }

    if (game) {
      // use downloaded data if exist
      gameData = parseJson(
          parser: () => GameData.fromJson({
                'servants': getJsonFromFile(
                    join(appData.gameDataPath, 'svt_list.json'),
                    k: Map()),
                'crafts': <String, String>{},
                'items': getJsonFromFile(
                    join(appData.gameDataPath, 'items.json'),
                    k: Map()),
                'icons': getJsonFromFile(
                    join(appData.gameDataPath, 'icons.json'),
                    k: Map())
              }),
          k: () => GameData());
      print('gamedata reloaded');
    }
  }

  T parseJson<T>({T parser(), T k()}) {
    T result;
    try {
      result = parser();
    } catch (e) {
      result = k();
      print('Error parsing json object to instance "$T"');
    }
    return result;
  }

  dynamic getJsonFromFile(String filename, {dynamic k}) {
    // dynamic: json object can be Map or List
    dynamic result;
    try {
      String contents = getLocalFile(filename).readAsStringSync();
      result = jsonDecode(contents);
      print('load json "$filename".');
    } catch (e) {
      result = k;
      print('error load "$filename", use defailt value. Error:\n$e');
    }
    return result;
  }

  File getLocalFile(String filename, {rel = ''}) {
    return File(join(_rootPath, rel, filename));
  }

  File getIconFile(String iconKey) {
    return File(join(_rootPath, appData.gameDataPath, 'icons',
        gameData.icons[iconKey].filename));
  }

  Future<Null> loadZipAssets(String assetKey,
      {String dir = 'temp', bool forceLoad = false}) async {
    String basePath = join(_rootPath, dir);
    if (forceLoad || !Directory(basePath).existsSync()) {
      //extract zip file
      final data = await rootBundle.load(assetKey);
      await extractZip(data.buffer.asUint8List().cast<int>(), basePath);
    }
    appData.gameDataPath = dir;
  }

  Future<Null> extractZip(List<int> bytes, String path) async {
    Archive archive = ZipDecoder().decodeBytes(bytes);
    print('------------------------------------------------------------');
    print('Zip file has been extracted, directory tree ($path)}):');
    for (ArchiveFile file in archive) {
      String fullFilepath = join(path, file.name);
      if (file.isFile) {
        List<int> data = file.content;
        File(fullFilepath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        print('file: ${file.name}');
      } else {
        Directory(fullFilepath)..create(recursive: true);
        print('dir : ${file.name}');
      }
    }
    print('end of zip tree.\n-----------------------------------------------');
  }

  //save data
  Future<Null> saveData() async {
    _saveJsonFile(appData, appDataFilename);
  }

  Future<Null> _saveJsonFile(dynamic jsonData, String relativePath) async {
    try {
      final contents = json.encode(jsonData);
      getLocalFile(relativePath).writeAsStringSync(contents);
      print('Saved "$relativePath"\n');
    } catch (e) {
      print('Error saving "$relativePath"!');
      print(e);
    }
  }

  // clear data
  Future<void> clearData(
      { bool app = false, bool game = false}) async {

    if (app) {
      _deleteFileOrDirectory(appDataFilename);
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(appData.gameDataPath);
    }
    await loadZipAssets('res/data/dataset.zip', dir: appData.gameDataPath);
    await loadData(app: app, game: game);
  }

  void _deleteFileOrDirectory(String relativePath) {
    String fullPath = join(_rootPath, relativePath);
    final type = FileSystemEntity.typeSync(fullPath, followLinks: false);

    if (type == FileSystemEntityType.directory) {
      Directory directory = Directory(fullPath);
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    } else if (type == FileSystemEntityType.file) {
      File file = File(fullPath);
      if (file.existsSync()) {
        File(fullPath).deleteSync();
      }
    }
  }

  /// internals
  static final _db = new Database._internal();

  factory Database() {
    return _db;
  }

  Database._internal();
}

Database db = new Database();
