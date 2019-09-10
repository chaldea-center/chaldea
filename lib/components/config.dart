import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chaldea/components/spec_delegate.dart'
    show LocaleChangeCallback;
import 'package:chaldea/components/constants.dart';
import 'datatypes/datatypes.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

/// app config:
///  - app database
///  - user database
class Database {
  LocaleChangeCallback onLocaleChange;
  AppData appData;
  Plans userData;
  GameData gameData;
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
      print('appdata reloaded');
    }

    if (user) {
      userData = Plans.fromJson(
          getJsonFromFile(userDataFilename, Map<String, dynamic>()));
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
    //todo: load and save hashCode, don't save if hashCode didn't change
    if (app) {
      try {
        final contents = json.encode(appData);
        getLocalFile(appDataFilename).writeAsStringSync(contents);
        print('Saved "$appDataFilename"\n');
      } catch (e) {
        print('Error saving "$appDataFilename"!');
        print(e);
      }
    }
    if (user) {
      try {
        final contents = json.encode(userData);
        getLocalFile(userDataFilename).writeAsStringSync(contents);
        print('Saved "$userDataFilename"\n');
      } catch (e) {
        print('Error saving "$userDataFilename"!');
        print(e);
      }
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
