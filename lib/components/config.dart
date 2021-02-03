//@dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as pathlib;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'datatypes/datatypes.dart';
import 'logger.dart';
import 'utils.dart';

/// app config:
///  - app database
///  - user database
class Database {
  /// setState for root [MaterialApp]
  VoidCallback onAppUpdate = () {};
  UserData userData = UserData();
  GameData gameData = GameData();
  SharedPreferences? _prefs;

  SharedPreferences get prefs => _prefs!;

  User get curUser {
    if (!userData.users.containsKey(userData.curUserKey)) {
      userData.curUserKey = userData.users.keys.first;
    }
    return userData.users[userData.curUserKey]!;
  }

  final ItemStatistics itemStat = ItemStatistics();
  final RuntimeData runtimeData = RuntimeData();

  static PathManager _paths = PathManager();

  PathManager get paths => _paths;

  // initialization
  Future<void> initial() async {
    await paths.initRootPath();
    _prefs ??= await SharedPreferences.getInstance();
    // Directory(paths.datasetCacheDir).createSync(recursive: true);
  }

  Future<void> checkNetwork() async {
    if (AppInfo.isMobile) {
      // connectivity not support windows
      if (db.userData.useMobileNetwork) {
        runtimeData.enableDownload = true;
      } else {
        final result = await Connectivity().checkConnectivity();
        runtimeData.enableDownload = result == ConnectivityResult.wifi;
      }
    } else {
      runtimeData.enableDownload =
          kDebugMode ? db.userData.useMobileNetwork : true;
    }
  }

  // data files operation
  bool loadUserData() {
    try {
      final newData = UserData.fromJson(
          getJsonFromFile(paths.userDataPath, k: () => <String, dynamic>{}));
      userData.dispose();
      userData = newData;
      logger.d('userdata reloaded.');
      return true;
    } catch (e, s) {
      logger.e('Load userdata failed', e, s);
      EasyLoading.showToast('Load userdata failed\n$e');
      return false;
    }
  }

  bool loadGameData() {
    final t = TimeCounter('loadGameData');
    try {
      gameData = GameData.fromJson(getJsonFromFile(paths.gameDataFilepath));
      logger.d('game data reloaded, version ${gameData.version}.');
      db.onAppUpdate.call();
      t.elapsed();
      itemStat.clear();
      itemStat.update();
      return true;
    } catch (e, s) {
      logger.e('Load game data failed', e, s);
      EasyLoading.showToast('Load game data failed\n$e');
      return false;
    }
  }

  Future<void> downloadGameData([String? url]) async {
    url ??= db.userData.serverDomain + kDatasetServerPath;
    Dio _dio = Dio();
    try {
      Response response = await _dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      print(response.headers);
      if (response.statusCode == 200) {
        File file = File(pathlib.join(db.paths.tempPath, 'dataset.zip'));
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        raf.closeSync();
        await extractZip(response.data, db.paths.gameDataDir);
        if (db.loadGameData()) {
          logger.i('Data downloaded! Version: ${db.gameData.version}');
          EasyLoading.showToast(
              'Data downloaded! Version: ${db.gameData.version}');
        } else {
          logger.i('Invalid data content! Version: ${db.gameData.version}');
          EasyLoading.showToast(
              'Invalid data content! Version: ${db.gameData.version}');
        }
      }
    } catch (e) {
      logger.w('Downloading error:\n$e');
      EasyLoading.showToast('Downloading error: $e');
      rethrow;
    }
  }

  Future<void> loadZipAssets(String assetKey,
      {String? extractDir, bool force = false}) async {
    final t = TimeCounter('loadZipAssets($assetKey)');
    extractDir ??= paths.gameDataDir;
    if (force || !Directory(extractDir).existsSync()) {
      //extract zip file
      final ByteData? data = await rootBundle.load(assetKey).catchError((e, s) {
        logger.e('Load assets failed: $assetKey', e, s);
        EasyLoading.showToast('Error load assets: $assetKey\n$e');
      });
      if (data != null)
        await extractZip(data.buffer.asUint8List().cast<int>(), extractDir);
      t.elapsed();
    }
  }

  void saveUserData() {
    _saveJsonToFile(userData, paths.userDataPath);
  }

  String backupUserdata() {
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
    String filepath =
        pathlib.join(paths.userDataDir, 'userdata-$timeStamp.json');
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
      await loadZipAssets(kDatasetAssetKey);
      loadGameData();
    }
  }

  IconResource? getIconResource(String iconKey, {bool? preferPng}) {
    final suffixes = preferPng == null
        ? ['', '.jpg', '.png']
        : preferPng == true
            ? ['.png', '', '.jpg']
            : ['.jpg', '', '.png'];
    for (var suffix in suffixes) {
      String key = iconKey + suffix;
      if (gameData.icons.containsKey(key)) {
        return gameData.icons[key];
      }
    }
    return null;
  }

  final AssetImage errorImage = AssetImage('res/img/gudako.png');

  ImageProvider getIconProvider(String iconKey, {bool? preferPng}) {
    final icon = getIconResource(iconKey, preferPng: preferPng);
    if (icon == null) {
      logger.e(
        'no such icon: $iconKey',
        ArgumentError.value(iconKey, 'iconKey'),
        StackTrace.current,
      );
      return errorImage;
    }
    return FileImage(
      File(pathlib.join(paths.gameIconDir, icon.name)),
    );
  }

  /// size of [Image] widget is zero before file is loaded to memory.
  /// [wrapContainer] to ensure the placeholder
  Widget getIconImage(
    String iconKey, {
    double? width,
    double? height,
    BoxFit? fit,
    bool wrapContainer = true,
    bool? preferPng,
  }) {
    final image = Image(
      image: getIconProvider(iconKey, preferPng: preferPng),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) => Container(
        width: width,
        height: height,
        child: child,
      ),
    );
    return image;
  }

  // assist methods
  dynamic getJsonFromFile(String filepath, {dynamic k()?}) {
    // dynamic: json object can be Map or List.
    // However, json_serializable always use Map->Class
    dynamic result;
    final file = File(filepath);
    try {
      if (file.existsSync()) {
        String contents = file.readAsStringSync();
        result = jsonDecode(contents);
        print('loaded json "$filepath".');
      }
    } catch (e, s) {
      print('error loading "$filepath", use default value. Error:\n$e\n$s');
      if (k == null) rethrow;
    } finally {
      if (result == null && k != null) {
        print('Loading "$filepath", use default value.');
        result = k();
      }
    }
    return result;
  }

  void _saveJsonToFile(dynamic jsonData, String filepath) {
    try {
      Directory(pathlib.dirname(filepath)).createSync(recursive: true);
      final contents = json.encode(jsonData);
      File(filepath).writeAsStringSync(contents);
      // print('Saved "$relativePath"\n');
    } catch (e, s) {
      print('Error saving "$filepath"!\n$e\n$s');
      EasyLoading.showToast('Error saving "$filepath"!\n$e');
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

  T? parseJson<T>({required T parser(), T k()?}) {
    T? result;
    try {
      result = parser();
    } catch (e, s) {
      result = k == null ? null : k();
      print('Error parsing json object to instance "$T"\n$e\n$s');
    }
    return result;
  }

  Future<void> extractZip(List<int> bytes, String path,
      {Function? onError, void Function(int, int)? onProgress}) async {
    final t = TimeCounter('extractZip');
    final errorMsg =
        await compute(_extractZipIsolate, {'bytes': bytes, 'path': path});
    if (errorMsg != null) {
      throw errorMsg;
    }
    t.elapsed();
  }

  static Future<String?> _extractZipIsolate(
      Map<String, dynamic> message) async {
    List<int> bytes = message['bytes'];
    String path = message['path'];
    Archive archive = ZipDecoder().decodeBytes(bytes);
    print('──────────────── Extract zip file ────────────────────────────────');
    print('extract zip file, directory tree "$path":');
    if (archive.findFile(kGameDataFilename) == null) {
      final exception =
          FormatException('Archive file doesn\'t contain $kGameDataFilename');
      print(exception);
      return exception.toString();
    }
    int iconCount = 0;
    for (ArchiveFile file in archive) {
      String fullFilepath = pathlib.join(path, file.name);
      if (file.isFile) {
        List<int> data = file.content;
        File(fullFilepath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        if (file.name.startsWith('icons/'))
          iconCount += 1;
        else
          print('file: ${file.name}');
      } else {
        Directory(fullFilepath)..create(recursive: true);
        print('dir : ${file.name}');
      }
    }
    print('icon files: total $iconCount files in "icons/"');
    print('──────────────── End zip file ────────────────────────────────────');
    return null;
  }

  // singleton
  static final _db = new Database._internal();

  factory Database() => _db;

  Database._internal();
}

class PathManager {
  /// [_appPath] root path where app can access
  static String? _appPath;

  /// [_savePath] root path to save user-related data
  static String? _savePath;

  /// [_tempPath] files can be deleted
  static String? _tempPath;

  Future<void> initRootPath() async {
    if (_appPath != null && _savePath != null && _tempPath != null) return;
    // final Map<String, Directory> _fps = {
    //   'ApplicationDocuments': await getApplicationDocumentsDirectory(),
    //   'Temporary': await getTemporaryDirectory(),
    //   'ApplicationSupport': await getApplicationSupportDirectory(),
    //   'Library': await getLibraryDirectory(),
    // };
    // for (var e in _fps.entries) {
    //   print('${e.key}\n\t\t${e.value.path}');
    // }

    if (Platform.isAndroid) {
      _appPath = (await getApplicationDocumentsDirectory()).path;
      _tempPath = (await getTemporaryDirectory()).path;
      // android: [emulated, external SD]
      _savePath = (await getExternalStorageDirectories())[0].path;
    } else if (Platform.isIOS) {
      _appPath = (await getApplicationDocumentsDirectory()).path;
      _tempPath = (await getTemporaryDirectory()).path;
      _savePath = _appPath;
    } else if (Platform.isWindows) {
      _appPath = (await getApplicationSupportDirectory()).path;
      _tempPath = (await getTemporaryDirectory()).path;
      _savePath = _appPath;
    } else if (Platform.isMacOS) {
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Documents
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Library/Caches
      _tempPath = (await getTemporaryDirectory()).path;
      _savePath = _appPath;
    } else {
      throw UnimplementedError('Not supported for ${Platform.operatingSystem}');
    }
  }

  String get appPath => _appPath!;

  String get savePath => _savePath!;

  String get tempPath => pathlib.join(_appPath!, 'temp');

  String get userDataDir => pathlib.join(_savePath!, 'user');

  String get userDataPath => pathlib.join(userDataDir, kUserDataFilename);

  String get gameDataDir => pathlib.join(_appPath!, 'data');

  String get gameDataFilepath => pathlib.join(gameDataDir, kGameDataFilename);

  String get gameIconDir => pathlib.join(gameDataDir, 'icons');

  String get crashLog => pathlib.join(_savePath!, 'crash.log');

  static PathManager _instance = PathManager._internal();

  PathManager._internal();

  factory PathManager() => _instance;
}

class RuntimeData {
  bool enableDownload = false;
//  final ItemStatistics itemStatistics = ItemStatistics();
}

Database db = new Database();
