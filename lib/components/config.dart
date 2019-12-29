import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/components.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'datatypes/datatypes.dart';

/// app config:
///  - app database
///  - user database
class Database {
  /// setState for root StatefulWidget
  VoidCallback onAppUpdate;
  UserData userData;
  GameData gameData;
  final RuntimeData runtimeData = RuntimeData();
  static PathManager _paths = PathManager();

  User get curUser => userData.users[userData.curUsername];

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
  Future<bool> loadUserData() async {
    userData = parseJson(
        parser: () => UserData.fromJson(getJsonFromFile(
              paths.userDataPath,
              k: () => <String, dynamic>{},
            )),
        k: () => UserData());
    print('appdata reloaded');
    return true;
  }

  Future<bool> loadGameData() async {
    // TODO: use downloaded data if exist
    try {
      gameData = GameData.fromJson(getJsonFromFile(paths.gameDataFilepath));
      print('gamedata reloaded, version ${gameData.version}.');
      return true;
    } catch (e) {
      gameData ??= GameData(); // if not null, don't change data
      print('load game data error:\n$e');
      showToast('ERROR load gamedata\n$e');
      return false;
    }
  }

  Future<Null> loadZipAssets(String assetKey,
      {String extractDir, bool force = false}) async {
    extractDir ??= paths.gameDataDir;
    if (force || !Directory(extractDir).existsSync()) {
      //extract zip file
      return rootBundle.load(assetKey).then((data) async {
        await extractZip(data.buffer.asUint8List().cast<int>(), extractDir);
      }, onError: (e, s) {
        print('Error load assets: $assetKey\n$e');
        showToast('Error load assets: $assetKey\n$e');
      });
    }
  }

  Future<Null> saveUserData() async {
    _saveJsonToFile(userData, paths.userDataPath);
  }

  Future<void> clearData({bool user = false, bool game = false}) async {
    if (user) {
      _deleteFileOrDirectory(paths.userDataPath);
      await loadUserData();
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(paths.gameDataDir);
      await loadZipAssets(kDefaultDatasetAssetKey);
      await loadGameData();
    }
  }

  ImageProvider getIconImage(String iconKey) {
    if (gameData.icons.containsKey(iconKey)) {
      return FileImage(File(
          join(paths.gameDataDir, 'icons', gameData.icons[iconKey].filename)));
    } else {
      print('error loading icon $iconKey');
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
    } catch (e) {
      result = k == null ? null : k();
      print('error load "$filepath", use defailt value. Error:\n$e');
    }
    return result;
  }

  Future<Null> _saveJsonToFile(dynamic jsonData, String filepath) async {
    try {
      final contents = json.encode(jsonData);
      File(filepath).writeAsStringSync(contents);
      // print('Saved "$relativePath"\n');
    } catch (e) {
      print('Error saving "$filepath"!\n$e');
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
    } catch (e) {
      result = k == null ? null : k();
      print('Error parsing json object to instance "$T"\n'
          'error=$e');
    }
    return result;
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
  final ItemStatistics itemStatistics = ItemStatistics();
}

Database db = new Database();
