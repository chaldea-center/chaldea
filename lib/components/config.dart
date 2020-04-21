import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'datatypes/datatypes.dart';
import 'utils.dart';

/// app config:
///  - app database
///  - user database
class Database {
  /// setState for root StatefulWidget
  VoidCallback onAppUpdate;
  UserData userData;
  GameData gameData;

  User get curUser => userData.users[userData.curUsername];

  final ItemStatistics itemStat = ItemStatistics();
  final RuntimeData runtimeData = RuntimeData();

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

  // data files operation
  bool loadUserData() {
    try {
      final newData = UserData.fromJson(
          getJsonFromFile(paths.userDataPath, k: () => <String, dynamic>{}));
      userData?.dispose();
      userData = newData;
      print('userdata reloaded.');
      return true;
    } catch (e, s) {
      userData ??= UserData(); // if not null, don't change data
      print('load userdata error:\n$e\n$s');
      showToast('ERROR load userdata\n$e');
      return false;
    }
  }

  bool loadGameData() {
    // TODO: use downloaded data if exist
    try {
      gameData = GameData.fromJson(getJsonFromFile(paths.gameDataFilepath));
      print('gamedata reloaded, version ${gameData.version}.');
      return true;
    } catch (e, s) {
      gameData ??= GameData(); // if not null, don't change data
      print('load game data error:\n$e\n$s');
      showToast('ERROR load gamedata\n$e');
      return false;
    }
  }

  Future<Null> loadZipAssets(String assetKey,
      {String extractDir, bool force = false}) {
    extractDir ??= paths.gameDataDir;
    if (force || !Directory(extractDir).existsSync()) {
      //extract zip file
      return rootBundle.load(assetKey).then((data) {
        extractZip(data.buffer.asUint8List().cast<int>(), extractDir);
      }, onError: (e, s) {
        print('Error load assets: $assetKey\n$e');
        showToast('Error load assets: $assetKey\n$e');
      });
    }
    return Future.value(null);
  }

  void saveUserData() {
    _saveJsonToFile(userData, paths.userDataPath);
  }

  String backupUserdata() {
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
    String filepath = join(paths.savePath, 'userdata-$timeStamp.json');
    _saveJsonToFile(userData, filepath);
    return filepath;
  }

  Future<void> clearData({bool user = false, bool game = false}) async {
    if (user) {
      _deleteFileOrDirectory(paths.userDataPath);
      loadUserData();
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(paths.gameDataDir);
      await loadZipAssets(kDefaultDatasetAssetKey);
      loadGameData();
    }
  }

  ImageProvider getIconImage(String iconKey) {
    if (gameData.icons.containsKey(iconKey)) {
      return FileImage(
          File(join(paths.gameIconDir, gameData.icons[iconKey].filename)));
    } else {
      print('no such icon: $iconKey');
      return AssetImage('res/img/error.png');
    }
  }

  // assist methods
  dynamic getJsonFromFile(String filepath, {dynamic k()}) {
    // dynamic: json object can be Map or List.
    // However, json_serializable always use Map->Class
    dynamic result;
    try {
      String contents = File(filepath).readAsStringSync();
      result = jsonDecode(contents);
      print('loaded json "$filepath".');
    } on FileSystemException catch (e) {
      result = k == null ? null : k();
      print('error loading "$filepath", use defailt value. Error:\n$e');
    } catch (e, s) {
      result = k == null ? null : k();
      print('error loading "$filepath", use defailt value. Error:\n$e\n$s');
    }
    return result;
  }

  void _saveJsonToFile(dynamic jsonData, String filepath) {
    try {
      final contents = json.encode(jsonData);
      File(filepath).writeAsStringSync(contents);
      // print('Saved "$relativePath"\n');
    } catch (e, s) {
      print('Error saving "$filepath"!\n$e\n$s');
      showToast('Error saving "$filepath"!\n$e');
    }
  }

  void _deleteFileOrDirectory(String path) {
    final type = FileSystemEntity.typeSync(path, followLinks: false);
    if (type == FileSystemEntityType.directory) {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    } else if (type == FileSystemEntityType.file) {
      File file = File(path);
      if (file.existsSync()) {
        File(path).deleteSync();
      }
    }
  }

  T parseJson<T>({T parser(), T k()}) {
    T result;
    try {
      result = parser();
    } catch (e, s) {
      result = k == null ? null : k();
      print('Error parsing json object to instance "$T"\n$e\n$s');
    }
    return result;
  }

  void extractZip(List<int> bytes, String path, {Function onError}) {
    Archive archive = ZipDecoder().decodeBytes(bytes);
    print('------------------------------------------------------------');
    print('Zip file has been extracted, directory tree ($path)}):');
    if (archive.findFile(kGameDataFilename) == null) {
      final exception =
          FormatException('Archive file doesn\'t contain $kGameDataFilename');
      if (onError != null) {
        onError(exception);
      } else {
        throw exception;
      }
    }
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

  // internals
  static final _db = new Database._internal();

  factory Database() => _db;

  Database._internal();
}

class PathManager {
  static String _appPath;
  static String _savePath;
  static String _tempPath;

  Future<Null> initRootPath() async {
    if (_appPath == null || _tempPath == null) {
      _appPath = (await getApplicationDocumentsDirectory()).path;
      _tempPath = (await getTemporaryDirectory()).path;
      if (Platform.isIOS) {
        _savePath = _appPath;
      } else {
        final dirs = await getExternalStorageDirectories();
        _savePath = dirs[dirs.length > 1 ? 1 : 0].path;
      }
    }
  }

  String get appPath => _appPath;

  String get savePath => _savePath;

  String get tempPath => _tempPath;

  String get userDataPath => join(_savePath, kUserDataFilename);

  String get gameDataDir => join(_appPath, 'dataset');

  String get gameDataFilepath => join(gameDataDir, kGameDataFilename);

  String get gameIconDir => join(gameDataDir, 'icons');

  String get datasetCacheDir => join(_appPath, 'datasets');

  String get crashLog => join(_tempPath, 'crash.log');

  static PathManager _instance = PathManager._internal();

  PathManager._internal();

  factory PathManager() => _instance;
}

class RuntimeData {
  bool enableDownload = false;
//  final ItemStatistics itemStatistics = ItemStatistics();
}

Database db = new Database();
