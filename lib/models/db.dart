import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/models/runtime_data.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/icon_clipper.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';
import '../app/api/hosts.dart';
import '../packages/app_info.dart';
import '../packages/language.dart';
import '../packages/method_channel/method_channel_chaldea.dart';
import '../packages/packages.dart';
import '../packages/split_route/split_route.dart';
import '../utils/hive_extention.dart';
import '../utils/json_helper.dart';
import 'gamedata/gamedata.dart';
import 'paths.dart';
import 'userdata/local_settings.dart';
import 'userdata/userdata.dart';

import 'package:flutter_web_plugins/url_strategy.dart'; // ignore: depend_on_referenced_packages

void _emptyCallback() {}

class _Database {
  // members
  final paths = PathManager();
  LocalSettings settings = LocalSettings();
  late final Box security;
  UserData _userData = UserData();

  UserData get userData => _userData;

  set userData(UserData userData) {
    _userData = userData;
    _userData.validate();
    itemCenter.init();
  }

  GameData _gameData = GameData();

  GameData get gameData => _gameData;

  set gameData(GameData gameData) {
    _gameData = gameData;
    _userData.validate();
    itemCenter.init();
  }

  RuntimeData runtimeData = RuntimeData();
  ItemCenter itemCenter = ItemCenter();

  // shortcut
  User get curUser => userData.curUser;

  UserPlan get curPlan_ => curUser.curPlan_;
  Map<int, SvtPlan> get curSvtPlan => curUser.curSvtPlan;
  VoidCallback notifyAppUpdate = _emptyCallback;

  // singleton
  static final _instance = _Database._internal();

  factory _Database() => _instance;

  _Database._internal() {
    _userNotifier = StreamController.broadcast();
    _settingNotifier = StreamController.broadcast();
    // _gameNotifier = ValueNotifier(gameData);
  }

  void dispose() {
    _userNotifier.close();
    _settingNotifier.close();
  }

  // listenable
  late final StreamController<UserData> _userNotifier;
  late final StreamController<LocalSettings> _settingNotifier;

  // late final ValueNotifier<GameData> _gameNotifier;

  void notifyUserdata() {
    _userNotifier.sink.add(userData);
    EasyDebounce.debounce('save_userdata', const Duration(seconds: 10), () {
      saveUserData();
      saveSettings();
    });
  }

  void notifySettings() {
    _settingNotifier.sink.add(settings);
  }

  Widget onUserData(AsyncWidgetBuilder<UserData> builder) {
    return StreamBuilder(
      initialData: userData,
      stream: _userNotifier.stream,
      builder: builder,
    );
  }

  Widget onSettings(AsyncWidgetBuilder<LocalSettings> builder) {
    return StreamBuilder(
      initialData: settings,
      stream: _settingNotifier.stream,
      builder: builder,
    );
  }

  Future<void> initiateForTest({
    required String testAppPath,
  }) async {
    await paths.initRootPath(testAppPath: testAppPath);
    Hive.init(paths.hiveDir);
    await loadSettings();
    settings.forceOnline = true;
    AppInfo.initiateForTest();
  }

  // methods
  Future<void> initiate() async {
    itemCenter.init();
    await paths.initRootPath();

    // init hive web fs first
    if (kIsWeb) {
      Hive.init(null);
      await FilePlus.initiate();
    } else {
      Hive.init(paths.hiveDir);
    }

    await loadSettings();
    await loadUserData().then((value) async {
      if (value != null) userData = value;
    });
    if (settings.splitMasterRatio != null) {
      SplitRoute.defaultMasterRatio = settings.splitMasterRatio!;
    }

    await AppInfo.resolve(paths.appPath);
    MethodChannelChaldea.configMethodChannel();

    // init other hive boxes at last
    security = await Hive.openBoxRetry('security');
    if (kIsWeb) setUrlStrategy(PathUrlStrategy());
    _startSavingLoop();
  }

  /// return the [UserData] instance, don't assign to [userData]
  Future<UserData?> loadUserData([String? fp]) async {
    return _loadWithBak<UserData?>(
      fp: fp ?? paths.userDataPath,
      fromJson: (data) => UserData.fromJson(data),
      onError: () => null,
    );
  }

  Future<LocalSettings> loadSettings([String? fp]) async {
    return settings = await _loadWithBak<LocalSettings>(
      fp: fp ?? paths.settingsPath,
      fromJson: (data) => LocalSettings.fromJson(data),
      onError: () => LocalSettings(),
    );
  }

  static const _backSuffix = '.bak';

  Future<T> _loadWithBak<T>({
    required String fp,
    required T Function(dynamic) fromJson,
    T Function()? onError,
  }) async {
    return JsonHelper.loadModel<T>(
      fp: fp,
      fromJson: fromJson,
      onError: () => JsonHelper.loadModel<T>(
        fp: fp + _backSuffix,
        fromJson: fromJson,
        onError: onError,
      ),
    );
  }

  Future<void> saveAll() async {
    await saveUserData();
    await saveSettings();
  }

  Future<void> saveUserData() => _saveWithBak(paths.userDataPath, userData);

  Future<void> saveSettings() => _saveWithBak(paths.settingsPath, settings);

  Future<void> _saveWithBak(String fp, Object obj) async {
    try {
      String content = jsonEncode(obj);
      await FilePlus(fp).writeAsString(content, flush: true);
      await FilePlus(fp + _backSuffix).writeAsString(content, flush: true);
    } catch (e, s) {
      if (kAppKey.currentContext != null) {
        EasyLoading.showError(e.toString());
      }
      logger.e('saving file failed', e, s);
    }
  }

  void _startSavingLoop() {
    String? _lastUserHash;
    String? _lastSettingHash;
    String _getHash(Object obj) {
      return md5.convert(utf8.encode(jsonEncode(obj))).toString();
    }

    Timer.periodic(const Duration(seconds: 10), (timer) {
      final _userHash = _getHash(userData);
      final _settingHash = _getHash(settings);
      if (_lastUserHash != null && _lastSettingHash != null) {
        if (_userHash != _lastUserHash) {
          saveUserData();
        }
        if (_settingHash != _lastSettingHash) {
          saveSettings();
        }
      }
      _lastUserHash = _userHash;
      _lastSettingHash = _settingHash;
    });
  }

  Future<List<String>> backupUserdata(
      {bool disk = false, bool memory = true}) async {
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());

    List<String> _saved = [];
    Future<void> _saveBytes(List<int> bytes, String fn) async {
      final fp = joinPaths(paths.backupDir, fn);
      await FilePlus(fp).writeAsBytes(bytes);
      _saved.add(fp);
    }

    final _lastSavedFile = FilePlus(paths.userDataPath);
    if (memory) {
      await _saveBytes(utf8.encode(jsonEncode(userData)),
          '${timeStamp}m-${userData.appVer}.json');
    }
    if (disk && _lastSavedFile.existsSync()) {
      await _saveBytes(
          await _lastSavedFile.readAsBytes(), '${timeStamp}d.json');
    }
    if (_saved.isNotEmpty) {
      db.settings.lastBackup = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    return _saved;
  }

  final AssetImage errorImage = const AssetImage('res/img/gudako.png');

  /// Only call this when [iconKey] SHOULD be saved to icon dir.
  /// If just want to use network image, use [CachedImage] instead.
  ///
  /// size of [Image] widget is zero before file is loaded to memory.
  /// wrap Container to ensure the placeholder size
  Widget getIconImage(
    String? iconUrl, {
    double? width,
    double? height,
    double? aspectRatio,
    BoxFit? fit,
    bool? preferPng,
    bool withBorder = true,
    bool? clip,
    EdgeInsetsGeometry? padding,
    WidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    VoidCallback? onTap,
  }) {
    Widget image;
    if (iconUrl == null || iconUrl.isEmpty) {
      image = Image(
        image: errorImage,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      image = CachedImage(
        imageUrl: iconUrl,
        // cacheDir: paths.gameIconDir,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        cachedOption: CachedImageOption(
          fit: fit,
          errorWidget: errorWidget ??
              (context, url, e) => SizedBox(
                    width: width,
                    height: height,
                    child: placeholder?.call(context),
                  ),
        ),
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
    if (onTap != null) {
      image = GestureDetector(onTap: onTap, child: image);
    }
    return image;
  }

  Dio get apiWorkerDio => DioE(BaseOptions(
        baseUrl: Hosts.workerHost,
        // baseUrl: kDebugMode ? 'http://localhost:8183' : ,
        queryParameters: {
          'app_ver': AppInfo.versionString,
          'user_key': AppInfo.uuid,
          'lang': Language.current.code,
          'os': PlatformU.operatingSystem
        },
      ));
}

final db = _Database();
// ignore: non_constant_identifier_names
ConstGameData get ConstData => db.gameData.constData;
