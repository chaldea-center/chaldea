import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:chaldea/widgets/icon_clipper.dart';
import 'package:chaldea/widgets/image/cached_image_option.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';
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
import 'datatypes/effect_type/effect_type.dart';
import 'device_app_info.dart';
import 'git_tool.dart';
import 'json_store/local_app_config.dart';
import 'logger.dart';
import 'method_channel_chaldea.dart';
import 'shared_prefs.dart';
import 'wiki_util.dart';

/// app config:
///  - app database
///  - user database
class Database {
  /// setState for root [MaterialApp]
  // ignore: prefer_function_declarations_over_variables
  VoidCallback notifyAppUpdate = () {};
  UserData userData = UserData();
  GameData gameData = GameData();

  AppSetting get appSetting => userData.appSetting;

  Dio get serverDio => Dio(BaseOptions(
        baseUrl: kServerRoot,
        // baseUrl: kDebugMode ? 'http://localhost:8183' : kServerRoot,
        queryParameters: {
          'app_ver': AppInfo.version,
          'user_key': AppInfo.uuid,
          'lang': Language.current.code,
          'os': PlatformU.operatingSystem
        },
        headers: {
          if (!PlatformU.isWeb) 'user-agent': HttpUtils.userAgentChaldea,
        },
      ));

  SharedPrefs prefs = SharedPrefs();
  late LocalAppConfig cfg;

  User get curUser => userData.curUser;

  Map<int, ServantPlan> get curPlan => curUser.curSvtPlan;

  final ItemStatistics itemStat = ItemStatistics();
  final RuntimeData runtimeData = RuntimeData();

  /// broadcast when user data updated
  /// It is used across the whole app lifecycle, so should not close it.
  StreamController<Database> broadcast = StreamController.broadcast();

  Future<void> notifyDbUpdate({bool item = false, bool svt = false}) async {
    if (item) {
      itemStat.clear();
      itemStat.update();
    }
    if (svt) {
      gameData.updateUserDuplicatedServants();
    }
    broadcast.sink.add(this);
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
    broadcast.close();
  }

  static final PathManager _paths = PathManager();

  PathManager get paths => _paths;

  ConnectivityResult? _connectivity;

  bool get hasNetwork =>
      _connectivity != null && _connectivity != ConnectivityResult.none;

  /// You should always check for connectivity status when your app is resumed
  Future<ConnectivityResult> checkConnectivity() async {
    _connectivity = await Connectivity().checkConnectivity();
    return _connectivity!;
  }

  Box? webFS;

  FlutterErrorDetails? initErrorDetail;

  // initialization before startup
  Future<void> initial() async {
    HttpOverrides.global = _MyHttpOverrides();

    initiateFuncBuffInstances();
    await paths.initRootPath();
    cfg = LocalAppConfig(pathlib.join(paths.configDir, 'cfg.json'),
        lapse: const Duration(seconds: 3));
    await WikiUtil.init();
    await AppInfo.resolve();
    await prefs.initiate();
    if (PlatformU.isWeb) {
      webFS = await Hive.openBox('WebFileSystem');
    }
    MethodChannelChaldea.configMethodChannel();
    await checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _connectivity = result;
    });
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
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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
      gameData.updateSvtCrafts();
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

  Future<void> loadZipAssets(String assetKey, {String? extractDir}) async {
    extractDir ??= paths.gameDir;
    final bytes =
        (await rootBundle.load(assetKey)).buffer.asUint8List().cast<int>();
    print('bytes: ${bytes.length}');
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
    if (PlatformU.isWeb) return [];
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
    String filename = '$timeStamp.json';

    List<String> _saved = [];
    File _lastSavedFile = File(paths.userDataPath);
    List objs = [
      if (disk && _lastSavedFile.existsSync()) _lastSavedFile,
      if (memory) userData,
    ];
    for (var obj in objs) {
      String filenameWithPrefix = filename + (obj is File ? 'd' : 'm');
      _saveJsonToFile(
        obj,
        pathlib.join(paths.userDataBackupDir, filenameWithPrefix),
        onError: (e, s) {
          logger.e('error save backup to ${paths.userDataBackupDir}', e, s);
          EasyLoading.showError(
              'Error saving to "${paths.userDataBackupDir}"!\n$e');
        },
        onSuccess: (fp) => _saved.add(fp),
      );
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
    if (!iconKey.contains('.') && db.gameData.items[iconKey] == null) {
      return iconKey + '.png';
    }
    // logger.d('Icon $iconKey not found');
    return iconKey;
  }

  final AssetImage errorImage = const AssetImage('res/img/gudako.png');

  // HashSet<String> _existsIcons =
  //     HashSet(isValidKey: (k) => k != null && k is String);

  /// Only call this when [iconKey] SHOULD be saved to icon dir.
  /// If just want to use network image, use [CachedImage] instead.
  ///
  /// size of [Image] widget is zero before file is loaded to memory.
  /// wrap Container to ensure the placeholder size
  Widget getIconImage(
    String? iconKey, {
    double? width,
    double? height,
    double? aspectRatio,
    BoxFit? fit,
    bool? preferPng,
    bool withBorder = true,
    bool? clip,
    EdgeInsetsGeometry? padding,
    WidgetBuilder? placeholder,
  }) {
    Widget image;
    if (iconKey == null || iconKey.isEmpty) {
      image = Image(
        image: errorImage,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      String iconName = getIconFullKey(iconKey,
          preferPng: preferPng, withBorder: withBorder)!;
      final originName = gameData.icons[iconName] ?? iconName;
      image = CachedImage(
        imageUrl: originName,
        cacheDir: paths.gameIconDir,
        cacheName: iconName,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        cachedOption: CachedImageOption(fit: fit),
        placeholder: (context, __) => SizedBox(
          width: width,
          height: height,
          child: placeholder?.call(context),
        ),
      );
    }
    if (clip != false) {
      image = ClipPath(
        clipper: TopCornerClipper(),
        child: image,
      );
    }
    if (padding != null) {
      image = Padding(padding: padding, child: image);
    }
    return image;
  }

  // assist methods
  dynamic getJsonFromFile(String filepath, {dynamic Function()? k}) {
    // dynamic: json object can be Map or List.
    // However, json_serializable always use Map->Class
    dynamic result;
    try {
      if (PlatformU.isWeb) {
        final contents = webFS!.get(paths.hiveAsciiKey(filepath));
        if (contents is String) {
          result = jsonDecode(contents);
        }
      } else {
        final file = File(filepath);
        if (file.existsSync()) {
          String contents = file.readAsStringSync();
          result = jsonDecode(contents);
          print('loaded json "$filepath".');
        }
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
      {void Function(Object e, StackTrace s)? onError,
      void Function(String fp)? onSuccess}) {
    try {
      if (PlatformU.isWeb) {
        webFS!.put(paths.hiveAsciiKey(filepath), json.encode(jsonDataOrFile));
      } else {
        Directory(pathlib.dirname(filepath)).createSync(recursive: true);
        final contents = jsonDataOrFile is File
            ? jsonDataOrFile.readAsStringSync()
            : json.encode(jsonDataOrFile);
        File(filepath).writeAsStringSync(contents);
      }
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
    if (PlatformU.isWeb) return;
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

  T? parseJson<T>({required T Function() parser, T Function()? k}) {
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
    Future Function(dynamic error, dynamic stackTrace)? onError,
    void Function(int, int)? onProgress,
  }) async {
    if (PlatformU.isWeb) return;
    // final t = TimeCounter('extractZip');
    if ([bytes, fp].where((e) => e != null).length != 1) {
      throw ArgumentError('You can/must only pass one parameter of bytes,fp');
    }
    if (fp != null) bytes = await File(fp).readAsBytes();
    final message = {'bytes': List.of(bytes!), 'savePath': savePath};
    if (onError == null) {
      await compute(_extractZipIsolate, message).catchError((e, s) async {
        logger.e('extract zip failed', e, s);
      });
    } else {
      await compute(_extractZipIsolate, message).catchError(onError);
    }
    // t.elapsed();
  }

  static Future<void> _extractZipIsolate(Map<String, dynamic> message) async {
    String savePath = message['savePath']!;
    List<int> bytes = List.of(message['bytes']!);
    Archive archive = ZipDecoder().decodeBytes(List.of(bytes));
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
        if (file.name.endsWith('.png') || file.name.endsWith('.jpg')) {
          iconCount += 1;
        } else {
          print('file: ${file.name}');
        }
      } else {
        Directory(fullFilepath).create(recursive: true);
        print('dir : ${file.name}');
      }
    }
    print('image files: total $iconCount files');
    print('──────────────── End zip file ────────────────────────────────────');
  }

  // singleton
  static final _db = Database._internal();

  factory Database() => _db;

  Database._internal();
}

class PathManager {
  /// [_appPath] root path where app can access
  String? _appPath;

  Future<void> initRootPath() async {
    // final Map<String, Directory?> _fps = {
    //   'ApplicationDocuments': await getApplicationDocumentsDirectory()
    //       .catchError((e) => Directory('null')),
    //   'ApplicationSupport': await getApplicationSupportDirectory()
    //       .catchError((e) => Directory('null')),
    //   'Temporary':
    //       await getTemporaryDirectory().catchError((e) => Directory('null')),
    //   'Library':
    //       await getLibraryDirectory().catchError((e) => Directory('null')),
    //   'Downloads':
    //       await getDownloadsDirectory().catchError((e) => Directory('null')),
    // };
    // for (var e in _fps.entries) {
    //   print('${e.key}\n\t\t${e.value?.path}');
    // }

    if (_appPath != null) return;
    if (PlatformU.isWeb) {
      _appPath = 'web';
      initiateLoggerPath('');
      return;
    }

    if (PlatformU.isAndroid) {
      // don't use getApplicationDocumentsDirectory, it is hidden to user.
      // android: [emulated, external SD]
      _appPath = (await getExternalStorageDirectories())![0].path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (PlatformU.isIOS) {
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (PlatformU.isMacOS) {
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Documents
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Library/Caches
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (PlatformU.isWindows) {
      // _tempPath = (await getTemporaryDirectory())?.path;
      // set link:
      // in old version windows, it may need admin permission, so it may fail
      String exeFolder = pathlib.dirname(PlatformU.resolvedExecutable);
      _appPath = pathlib.join(exeFolder, 'userdata');
      if (kDebugMode) {
        // C:\Users\<user>\AppData\Roaming\cc.narumi\Chaldea
        _appPath = (await getApplicationSupportDirectory()).path;
      }
    } else if (PlatformU.isLinux) {
      String exeFolder = pathlib.dirname(PlatformU.resolvedExecutable);
      _appPath = pathlib.join(exeFolder, 'userdata');
      if (kDebugMode) {
        // Ubuntu: /home/<user>/.local/share/chaldea
        _appPath = (await getApplicationSupportDirectory()).path;
      }
    } else {
      throw UnimplementedError(
          'Not supported for ${PlatformU.operatingSystem}');
    }
    if (_appPath == null) {
      throw const OSError('Cannot resolve document folder');
    }

    // ensure directory exist
    for (String dir in [
      userDir,
      gameDir,
      tempDir,
      downloadDir,
      gameIconDir,
      logDir
    ]) {
      Directory(dir).createSync(recursive: true);
    }
    // logger
    initiateLoggerPath(appLog);
    // crash files
    final File crashFile = File(crashLog);
    if (!crashFile.existsSync()) {
      crashFile.writeAsString('chaldea.crash.log\n', flush: true);
    }
    rollLogFiles(crashFile.path, 3, 1 * 1024 * 1024);
  }

  String convertIosPath(String p) {
    return PlatformU.isIOS
        ? p.replaceFirst(appPath, S.current.ios_app_path)
        : p;
  }

  String hiveAsciiKey(String s) {
    return Uri.tryParse(s)?.toString() ?? s;
  }

  String get appPath => _appPath!;

  String get gameDir => pathlib.join(_appPath!, 'data');

  String get userDir => pathlib.join(_appPath!, 'user');

  String get tempDir => pathlib.join(_appPath!, 'temp');

  String get downloadDir => pathlib.join(_appPath!, 'downloads');

  String get configDir => pathlib.join(_appPath!, 'config');

  String get userDataPath => pathlib.join(userDir, kUserDataFilename);

  String get userDataBackupDir => pathlib.join(appPath, 'backup');

  String get gameDataPath => pathlib.join(gameDir, kGameDataFilename);

  String get gameIconDir => pathlib.join(gameDir, 'icons');

  String get logDir => pathlib.join(_appPath!, 'logs');

  String get appLog => pathlib.join(logDir, 'log.log');

  String get crashLog => pathlib.join(logDir, 'crash.log');

  String get datasetVersionFile => pathlib.join(gameDir, 'VERSION');

  static final PathManager _instance = PathManager._internal();

  PathManager._internal();

  factory PathManager() => _instance;
}

class RuntimeData {
  Version? upgradableVersion;
  DatasetVersion? latestDatasetVersion;
  double? criticalWidth;
  Set<String> itemRecognizeImageFiles = {};
  Set<String> activeSkillRecognizeImageFiles = {};
  Set<String> appendSkillRecognizeImageFiles = {};
  bool googlePlayAccess = false;

  bool _showDebugFAB = true;

  bool get showDebugFAB =>
      _showDebugFAB && (kDebugMode || AppInfo.isDebugDevice);

  set showDebugFAB(bool value) => _showDebugFAB = value;

  /// Controller of [Screenshot] widget which set root [MaterialApp] as child
  ScreenshotController? screenshotController;

  /// store anything you like
  Map<dynamic, dynamic> tempDict = {};
}

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Database db = Database();
