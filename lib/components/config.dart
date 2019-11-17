import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
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
  bool enableDownload;

  Plans get curPlan => userData.users[userData.curUser]?.plans;
  static String _rootPath = '';

  String get rootPath => _rootPath;

  // initialization
  Future<Null> initial() async {
    _rootPath = (await getApplicationDocumentsDirectory()).path;
  }

  Future<Null> checkNetwork() async {
    final result = await Connectivity().checkConnectivity();
    enableDownload = (!kDebugMode || db.userData.testAllowDownload) &&
        (db.userData.useMobileNetwork || result != ConnectivityResult.mobile);
    print(
        'kDebugMode=$kDebugMode,\ntestAllowDown=${db.userData.testAllowDownload},\n'
        'useMobile=${db.userData.useMobileNetwork},\nnetwork=$result,\n'
        'enableDown=$enableDownload');
  }

  // load data
  Future<Null> loadGameData() async {
    // TODO: use downloaded data if exist
    dynamic _getGameJson(Map<String, String> paths) => paths.map((key, fn) =>
        MapEntry(key, getJsonFromFile(join(userData.gameDataPath, fn))));
    gameData = parseJson(
        parser: () => GameData.fromJson(_getGameJson({
              'servants': 'servants.json',
              'crafts': 'crafts.json',
              'items': 'items.json',
              'icons': 'icons.json',
              'events': 'events.json'
            })),
        k: () => GameData());
    print('gamedata reloaded');
  }

  Future<Null> loadUserData() async {
    userData = parseJson(
        parser: () =>
            UserData.fromJson(getJsonFromFile(userDataFilename, k: {})),
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

  dynamic getJsonFromFile(String filename, {dynamic k}) {
    // dynamic: json object can be Map or List.
    // However, json_serializable always use Map->Class
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
    if (gameData.icons.containsKey(iconKey)) {
      return File(join(_rootPath, userData.gameDataPath, 'icons',
          gameData.icons[iconKey].filename));
    } else {
      //todo: replace with error.png
      return null;
    }
  }

  Future<Null> loadAssetsData(String assetKey,
      {String dir, bool force = false}) async {
    dir ??= userData?.gameDataPath ?? 'temp';
    String basePath = join(_rootPath, dir);
    if (force || !Directory(basePath).existsSync()) {
      //extract zip file
      final data = await rootBundle.load(assetKey);
      await extractZip(data.buffer.asUint8List().cast<int>(), basePath);
    }
    userData.gameDataPath = dir;
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
    _saveJsonFile(userData, userDataFilename);
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
    final oldPath = userData.gameDataPath;
    if (user) {
      _deleteFileOrDirectory(userDataFilename);
      await loadUserData();
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(oldPath);
    }
    await loadAssetsData('res/data/dataset.zip', dir: userData.gameDataPath);
    await loadGameData();
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
