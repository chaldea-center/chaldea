import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as pathlib;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'constants.dart';
import 'datatypes/datatypes.dart';
import 'device_app_info.dart';
import 'git_tool.dart';
import 'logger.dart';
import 'shared_prefs.dart';

/// app config:
///  - app database
///  - user database
class Database {
  /// setState for root [MaterialApp]
  VoidCallback notifyAppUpdate = () {};
  UserData userData = UserData();
  GameData gameData = GameData();
  Dio serverDio = Dio(BaseOptions(baseUrl: kServerRoot));

  SharedPrefs prefs = SharedPrefs();
  late Box cfg;

  User get curUser => userData.curUser;

  final ItemStatistics itemStat = ItemStatistics();
  final RuntimeData runtimeData = RuntimeData();

  /// broadcast when user data updated
  /// It is used across the whole app lifecycle, so should not close it.
  StreamController<Database> broadcast = StreamController.broadcast();

  Future<void> notifyDbUpdate([bool recalculateItemStat = false]) async {
    if (recalculateItemStat) {
      itemStat.clear();
      itemStat.update();
    }
    this.broadcast.sink.add(this);
  }

  /// widgets depending on database which may change
  Widget streamBuilder(WidgetBuilder builder) {
    return StreamBuilder<Database>(
      initialData: db,
      stream: db.broadcast.stream,
      builder: (context, snapshot) => builder(context),
    );
  }

  void dispose() {
    this.broadcast.close();
  }

  static PathManager _paths = PathManager();

  PathManager get paths => _paths;

  ConnectivityResult? _connectivity;

  ConnectivityResult get connectivity =>
      _connectivity ?? ConnectivityResult.none;

  /// You should always check for connectivity status when your app is resumed
  Future<ConnectivityResult> checkConnectivity() async {
    _connectivity = await Connectivity().checkConnectivity();
    return _connectivity!;
  }

  // initialization before startup
  Future<void> initial() async {
    await paths.initRootPath();
    Hive.init(paths.configDir);
    await AppInfo.resolve();
    await prefs.initiate();
    cfg = await Hive.openBox('cfg');
    await checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _connectivity = result;
    });
    MethodChannelChaldea.configMethodChannel();
  }

  /// Automatically save user data when:
  /// - A repeating timer every 30 seconds and userdata has been changed
  /// - when app becomes [AppLifecycleState.inactive]
  Timer? _autoSaveTimer;
  String? _lastSavedUserData;

  // data files operation
  bool loadUserData([UserData? data]) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    bool result;
    try {
      final newData = data ??
          UserData.fromJson(getJsonFromFile(paths.userDataPath,
              k: () => <String, dynamic>{}));
      userData = newData;
      gameData.updateUserDuplicatedServants();
      userData.validate();
      logger.d('userdata loaded.');
      result = true;
      _lastSavedUserData = jsonEncode(userData);
    } catch (e, s) {
      logger.e('Load userdata failed', e, s);
      EasyLoading.showToast('Load userdata failed\n$e');
      result = false;
    }
    _autoSaveTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      String curData = jsonEncode(userData);
      if (_lastSavedUserData == null || curData != _lastSavedUserData) {
        saveUserData();
      }
    });
    return result;
  }

  bool loadGameData([GameData? data]) {
    // final t = TimeCounter('loadGameData');
    try {
      gameData = data ?? GameData.fromJson(getJsonFromFile(paths.gameDataPath));
      // userdata is loaded before gamedata, safe to use curUser
      gameData.updateUserDuplicatedServants();
      userData.validate();
      logger.d('game data loaded, version ${gameData.version}.');
      // t.elapsed();
      itemStat.clear();
      itemStat.update();
      db.notifyAppUpdate();
      return true;
    } catch (e, s) {
      logger.e('Load game data failed', e, s);
      EasyLoading.showToast('Load game data failed\n$e');
      return false;
    }
  }

  Future<void> downloadGameData([String? url]) async {
    url ??= db.userData.serverRoot ?? kServerRoot + kDatasetServerPath;
    Dio _dio = Dio();
    try {
      Response response = await _dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      print(response.headers);
      if (response.statusCode == 200) {
        File file = File(pathlib.join(db.paths.tempDir, 'dataset.zip'));
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        raf.closeSync();
        await extractZip(bytes: response.data, savePath: db.paths.gameDir);
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

  Future<void> loadZipAssets(String assetKey, {String? extractDir}) async {
    extractDir ??= paths.gameDir;
    final bytes =
        (await rootBundle.load(assetKey)).buffer.asUint8List().cast<int>();
    await extractZip(bytes: bytes, savePath: extractDir);
  }

  void saveUserData() {
    bool shouldBackup = false;

    _saveJsonToFile(userData, paths.userDataPath, onError: (e, s) {
      logger.e('error save userdata to ${paths.userDataPath}', e, s);
      EasyLoading.showToast('Error saving userdata!\n$e');
    });

    int? lastDateInt = prefs.instance.getInt('lastSavedDate');
    DateTime now = DateTime.now();
    if (lastDateInt == null) {
      shouldBackup = true;
    } else {
      DateTime _lastDate = DateTime.fromMillisecondsSinceEpoch(lastDateInt);
      if (now.month != _lastDate.month || now.day != _lastDate.day) {
        shouldBackup = true;
      }
    }
    if (shouldBackup) {
      backupUserdata();
      prefs.instance.setInt('lastSavedDate', now.millisecondsSinceEpoch);
    }
  }

  List<String> backupUserdata({bool disk = false, bool memory = true}) {
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
    String filename = '$timeStamp.json';

    List<String> _saved = [];
    File _lastSavedFile = File(paths.userDataPath);
    List objs = [
      if (disk && _lastSavedFile.existsSync()) _lastSavedFile,
      if (memory) userData,
    ];
    for (var obj in objs) {
      String filenameWithPrefix = (obj is File ? 'd' : 'm') + filename;
      _saveJsonToFile(
        obj,
        join(paths.userDataBackupDir, filenameWithPrefix),
        onError: (e, s) {
          logger.e('error save backup to ${paths.userDataBackupDir}', e, s);
          EasyLoading.showError(
              'Error saving to "${paths.userDataBackupDir}"!\n$e');
        },
        onSuccess: (fp) => _saved.add(fp),
      );

      if (paths.externalAppPath != null) {
        final _externalFp =
            join(paths.externalAppPath!, 'backup', filenameWithPrefix);
        logger.i('ready to write into $_externalFp');
        _saveJsonToFile(
          obj,
          _externalFp,
          onError: (e, s) {
            logger.e('error save backup to $_externalFp', e, s);
            paths.externalAppPath = null;
          },
          onSuccess: (fp) => _saved.add(fp),
        );
      }
    }
    return _saved;
  }

  Future<void> clearData({bool user = false, bool game = false}) async {
    if (user) {
      _deleteFileOrDirectory(paths.userDataPath);
      loadUserData();
      db.itemStat
        ..clear()
        ..update();
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(paths.gameDir);
      await loadZipAssets(kDatasetAssetKey);
      loadGameData();
    }
  }

  String? getIconFullKey(String? iconKey,
      {bool? preferPng, bool withBorder = true}) {
    if (iconKey == null) return null;
    String modifiedKey = iconKey;
    if (iconKey.endsWith('.png') || iconKey.endsWith('.jpg')) {
      modifiedKey = iconKey.substring(0, iconKey.length - 4);
    }
    List<String> keys = withBorder
        ? [modifiedKey + '(有框)', modifiedKey]
        : [modifiedKey, modifiedKey + '(有框)'];
    for (String key in keys) {
      final suffixes = preferPng == null
          ? ['', '.jpg', '.png']
          : preferPng == true
              ? ['.png', '', '.jpg']
              : ['.jpg', '', '.png'];
      for (var suffix in suffixes) {
        String fullKey = key + suffix;
        if (gameData.icons.containsKey(fullKey)) {
          return fullKey;
        }
      }
    }
    // logger.d('Icon $iconKey not found');
    return iconKey;
  }

  final AssetImage errorImage = AssetImage('res/img/gudako.png');

  /// Only call this when [iconKey] SHOULD be saved to icon dir.
  /// If just want to use network image, use [CachedImage] instead.
  ///
  /// size of [Image] widget is zero before file is loaded to memory.
  /// wrap Container to ensure the placeholder size
  Widget getIconImage(
    String? iconKey, {
    double? width,
    double? height,
    BoxFit? fit,
    bool? preferPng,
    bool withBorder = true,
  }) {
    if (iconKey == null) {
      return Image(
        image: errorImage,
        width: width,
        height: height,
        fit: fit,
      );
    }
    String iconName =
        getIconFullKey(iconKey, preferPng: preferPng, withBorder: withBorder)!;
    File iconFile = File(pathlib.join(paths.gameIconDir, iconName));
    if (iconFile.existsSync()) {
      return Image(
        image: FileImage(iconFile),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) => Container(
          width: width,
          height: height,
          child: child,
        ),
      );
    } else {
      return CachedImage(
        imageUrl: iconName,
        saveDir: db.paths.gameIconDir,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(width: width, height: height),
      );
    }
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

  void _saveJsonToFile(dynamic jsonDataOrFile, String filepath,
      {void onError(Object e, StackTrace s)?, void onSuccess(String fp)?}) {
    try {
      Directory(pathlib.dirname(filepath)).createSync(recursive: true);
      final contents = jsonDataOrFile is File
          ? jsonDataOrFile.readAsStringSync()
          : json.encode(jsonDataOrFile);
      File(filepath).writeAsStringSync(contents);
    } catch (e, s) {
      if (onError != null) {
        return onError(e, s);
      }
      rethrow;
    }
    if (onSuccess != null) onSuccess(filepath);
    // print('Saved "$relativePath"\n');
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

  /// You must provide one and only one parameter of [bytes] or [assetKey] or [fp]
  Future<void> extractZip({
    List<int>? bytes,
    String? fp,
    required String savePath,
    Function(dynamic error, dynamic stackTrace)? onError,
    void Function(int, int)? onProgress,
  }) async {
    // final t = TimeCounter('extractZip');
    if ([bytes, fp].where((e) => e != null).length != 1) {
      throw ArgumentError('You can/must only pass one parameter of bytes,fp');
    }
    if (fp != null) bytes = await File(fp).readAsBytes();
    final message = {'bytes': bytes, 'savePath': savePath};
    if (onError == null) {
      await compute(_extractZipIsolate, message);
    } else {
      await compute(_extractZipIsolate, message).catchError(onError);
    }
    // t.elapsed();
  }

  static Future<void> _extractZipIsolate(Map<String, dynamic> message) async {
    String savePath = message['savePath']!;
    List<int> bytes = message['bytes']!;

    Archive archive = ZipDecoder().decodeBytes(bytes);
    print('──────────────── Extract zip file ────────────────────────────────');
    print('extract zip file, directory tree "$savePath":');
    // if (archive.findFile(kGameDataFilename) == null) {
    //    throw FormatException('Archive file doesn\'t contain $kGameDataFilename');
    // }
    int iconCount = 0;
    for (ArchiveFile file in archive) {
      String fullFilepath = pathlib.join(savePath, file.name);
      if (file.isFile) {
        List<int> data = file.content;
        File(fullFilepath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        if (file.name.endsWith('.png') || file.name.endsWith('.jpg'))
          iconCount += 1;
        else
          print('file: ${file.name}');
      } else {
        Directory(fullFilepath)..create(recursive: true);
        print('dir : ${file.name}');
      }
    }
    print('image files: total $iconCount files');
    print('──────────────── End zip file ────────────────────────────────────');
  }

  // singleton
  static final _db = new Database._internal();

  factory Database() => _db;

  Database._internal();
}

class PathManager {
  /// [_appPath] root path where app can access
  String? _appPath;
  String? externalAppPath;

  Future<void> initRootPath() async {
    if (_appPath != null) return;
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
      // don't use getApplicationDocumentsDirectory, it is hidden to user.
      // android: [emulated, external SD]
      _appPath = (await getExternalStorageDirectories())![0].path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (Platform.isIOS) {
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (Platform.isWindows) {
      _appPath = (await getApplicationSupportDirectory()).path;
      // _tempPath = (await getTemporaryDirectory())?.path;
      // set link:
      // in old version windows, it may need admin permission, so it may fail
      try {
        String exeFolder = pathlib.dirname(Platform.resolvedExecutable);
        String linkPath = pathlib.join(exeFolder, 'userdata');
        Link link = Link(linkPath);
        DateTime now = DateTime.now();
        switch (FileSystemEntity.typeSync(linkPath, followLinks: false)) {
          case FileSystemEntityType.notFound:
            break;
          case FileSystemEntityType.file:
            File(linkPath).renameSync(
                linkPath + '.bak${now.millisecondsSinceEpoch ~/ 1000}');
            break;
          case FileSystemEntityType.directory:
            Directory(linkPath).renameSync(
                linkPath + '.bak${now.millisecondsSinceEpoch ~/ 1000}');
            break;
          case FileSystemEntityType.link:
            if (FileSystemEntity.identicalSync(
                link.resolveSymbolicLinksSync(), _appPath!)) {
              // pass
            } else {
              link.update(_appPath!);
            }
            break;
        }
        if (!link.existsSync()) {
          link.createSync(_appPath!, recursive: true);
        }
      } catch (e, s) {
        logger.e('make link failed', e, s);
      }
    } else if (Platform.isMacOS) {
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Documents
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Library/Caches
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else {
      throw UnimplementedError('Not supported for ${Platform.operatingSystem}');
    }
    if (_appPath == null) {
      throw OSError('Cannot resolve document folder');
    }
    for (String dir in [userDir, gameDir, tempDir, gameIconDir, logDir]) {
      Directory(dir).createSync(recursive: true);
    }
    initiateLoggerPath(appLog);
  }

  String get appPath => _appPath!;

  String get gameDir => pathlib.join(_appPath!, 'data');

  String get userDir => pathlib.join(_appPath!, 'user');

  String get tempDir => pathlib.join(_appPath!, 'temp');

  String get configDir => pathlib.join(_appPath!, 'config');

  String get userDataPath => pathlib.join(userDir, kUserDataFilename);

  String get userDataBackupDir => pathlib.join(appPath, 'backup');

  String get gameDataPath => pathlib.join(gameDir, kGameDataFilename);

  String get gameIconDir => pathlib.join(gameDir, 'icons');

  String get logDir => pathlib.join(_appPath!, 'logs');

  String get appLog => pathlib.join(logDir, 'log.log');

  String get crashLog => pathlib.join(logDir, 'crash.log');

  String get datasetVersionFile => pathlib.join(gameDir, 'VERSION');

  static PathManager _instance = PathManager._internal();

  PathManager._internal();

  factory PathManager() => _instance;
}

class RuntimeData {
  Version? upgradableVersion;
  double? criticalWidth;
  List<File> itemRecognizeImageFiles = [];
  bool googlePlayAccess = false;

  /// Controller of [Screenshot] widget which set root [MaterialApp] as child
  ScreenshotController? screenshotController;
}

Database db = new Database();
