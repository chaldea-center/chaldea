import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'datatypes/datatypes.dart';

/// app config:
///  - app database
///  - user database
class Database {
  VoidCallback onAppUpdate;
  UserData userData;
  GameData gameData;
  final RuntimeData runtimeData = RuntimeData();

  Plans get curPlan => userData.users[userData.curUser]?.plans;
  static PathManager _paths = PathManager();

  PathManager get paths => _paths;

  // initialization
  Future<Null> initial() async {
    await paths.initRootPath();
    Directory(paths.datasetCacheDir).createSync(recursive: true);
  }

  Future<Null> checkNetwork() async {
    final result = await Connectivity().checkConnectivity();
    runtimeData.enableDownload = (!kDebugMode ||
            db.userData.testAllowDownload) &&
        (db.userData.useMobileNetwork || result != ConnectivityResult.mobile);
  }

  // load data
  Future<Null> loadGameData() async {
    // TODO: use downloaded data if exist
    gameData = parseJson(
        parser: () => GameData.fromJson(getJsonFromFile(
              paths.gameDataFilepath,
              k: () => <String, dynamic>{},
            )),
        k: () => GameData());
    print('gamedata reloaded, version ${gameData.version}.');
  }

  Future<Null> loadUserData() async {
    userData = parseJson(
        parser: () => UserData.fromJson(getJsonFromFile(
              kUserDataFilename,
              k: () => <String, dynamic>{},
            )),
        k: () => UserData());
    print('appdata reloaded');
  }

  T parseJson<T>({T parser(), T k()}) {
    T result;
    try {
      result = parser();
    } catch (e) {
      result = k == null ? null : k();
      print('Error parsing json object to instance "$T"\n'
          'error=$e');
    }
    return result;
  }

  dynamic getJsonFromFile(String filename, {dynamic k()}) {
    // dynamic: json object can be Map or List.
    // However, json_serializable always use Map->Class
    dynamic result;
    try {
      String contents = getLocalFile(filename).readAsStringSync();
      result = jsonDecode(contents);
      print('load json "$filename".');
    } catch (e) {
      result = k == null ? null : k();
      print('error load "$filename", use defailt value. Error:\n$e');
    }
    return result;
  }

  File getLocalFile(String filename, {rel = ''}) {
    return File(join(paths.rootPath, rel, filename));
  }

  ImageProvider getIconFile(String iconKey) {
    if (gameData.icons.containsKey(iconKey)) {
      return FileImage(File(
          join(paths.gameDataDir, 'icons', gameData.icons[iconKey].filename)));
    } else {
      print('error loading icon $iconKey');
      return AssetImage('res/img/error.png');
    }
  }

  Future<Null> loadAssetsData(String assetKey,
      {String relPath, bool force = false}) async {
    String extractDir =
        relPath == null ? paths.gameDataDir : join(paths.rootPath, relPath);
    if (force || !Directory(extractDir).existsSync()) {
      //extract zip file
      final data = await rootBundle.load(assetKey);
      await extractZip(data.buffer.asUint8List().cast<int>(), extractDir);
    }
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
    _saveJsonFile(userData, kUserDataFilename);
  }

  Future<Null> _saveJsonFile(dynamic jsonData, String relativePath) async {
    try {
      final contents = json.encode(jsonData);
      getLocalFile(relativePath).writeAsStringSync(contents);
      // print('Saved "$relativePath"\n');
    } catch (e) {
      print('Error saving "$relativePath"!');
      print(e);
    }
  }

  // clear data
  Future<void> clearData({bool user = false, bool game = false}) async {
    if (user) {
      _deleteFileOrDirectory(kUserDataFilename, relative: true);
      await loadUserData();
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(paths.gameDataDir);
    }
    await loadAssetsData(kDefaultDatasetAssetKey);
    await loadGameData();
  }

  void _deleteFileOrDirectory(String path, {bool relative = false}) {
    String fullPath = relative ? join(paths.gameDataDir, path) : path;
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

class PathManager {
  static String _rootPath;
  static String _tempDir;

  Future<Null> initRootPath() async {
    if (_rootPath == null || _tempDir == null) {
      _rootPath = (await getApplicationDocumentsDirectory()).path;
      _tempDir = (await getTemporaryDirectory()).path;
    }
  }

  String get rootPath => _rootPath;

  String get tempDir => _tempDir;

  String get gameDataDir => join(_rootPath, 'dataset');

  String get gameDataFilepath => join(gameDataDir, kGameDataFilename);

  String get gameIconDir => join(gameDataDir, 'icons');

  String get datasetCacheDir => join(_rootPath, 'datasets');

  String get crashLog => join(_tempDir, 'crash.log');
}

class RuntimeData {
  bool enableDownload = false;
  ItemsOfSvts itemsOfSvts = ItemsOfSvts();
  Map<String, int> itemsOfEvents = {};
}

Database db = new Database();
