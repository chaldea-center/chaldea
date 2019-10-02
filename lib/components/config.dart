import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/constants.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'datatypes/datatypes.dart';

/// app config:
///  - app database
///  - user database
class Database {
  LocaleChangeCallback onLocaleChange;
  AppData appData;
  Plans userData;
  GameData gameData;
  Map<String, int> hashCodes = {};
  static String _rootPath = '';

  String get rootPath => _rootPath;

  // initialization
  Future<Null> initial() async {
    _rootPath = (await getApplicationDocumentsDirectory()).path;
  }

  Future<Null> loadData(
      {bool user = true, bool app = true, bool game = true}) async {
    if (app) {
      appData = AppData.fromJson(
          getJsonFromFile(appDataFilename, Map<String, dynamic>()));
      hashCodes['app'] = appData.hashCode;
      print('appdata reloaded');
    }

    if (user) {
      userData = Plans.fromJson(
          getJsonFromFile(userDataFilename, Map<String, dynamic>()));
      hashCodes['user'] = userData.hashCode;
      print('userdata reloaded');
    }
    if (game) {
      // use downloaded data if exist
      gameData = GameData.fromJson({
        'servants':
        getJsonFromFile(join(appData.gameDataPath, 'svt_list.json'), Map()),
        'crafts': <String, String>{},
        'items':
        getJsonFromFile(join(appData.gameDataPath, 'items.json'), Map()),
        'icons':
        getJsonFromFile(join(appData.gameDataPath, 'icons.json'), Map())
      });
      print('gamedata reloaded');
    }
  }

  Future<Null> saveData({bool app: false, bool user: false}) async {
    if (app) {
      _saveJsonFile(appData, appDataFilename);
//      int newCode = appData.hashCode;
//      if (hashCodes['app'] != newCode) {
//        print('appData hashCode changed, saving file.');
//        hashCodes['app'] = newCode;
//        _saveJsonFile(appData, appDataFilename);
//      }
    }
    if (user) {
      _saveJsonFile(userData, userDataFilename);
//      int newCode = userData.hashCode;
//      if (hashCodes['user'] != newCode) {
//        print('userData hashCode changed, saving file.');
//        hashCodes['user'] = newCode;
//        _saveJsonFile(userData, userDataFilename);
//      }else{
//        print('userData hashCode no change: ${userData.servants}');
//      }
    }
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

  Future<void> clearData(
      {bool user = false, bool app = false, bool game = false}) async {
    if (user) {
      _deleteFileOrDirectory(userDataFilename);
    }
    if (app) {
      _deleteFileOrDirectory(appDataFilename);
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(appData.gameDataPath);
    }
    await loadZipAssets('res/data/dataset.zip', dir: appData.gameDataPath);
    await loadData(app: app, user: user, game: game);
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

  File getLocalFile(String filename, {rel = ''}) {
    return File(join(_rootPath, rel, filename));
  }

  File getIconFile(String iconKey) {
    return File(join(_rootPath, appData.gameDataPath, 'icons',
        gameData.icons[iconKey].filename));
  }

  dynamic getJsonFromFile(String filename, dynamic k) {
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

  /// internals
  static final _db = new Database._internal();

  factory Database() {
    return _db;
  }

  Database._internal();
}

Database db = new Database();
