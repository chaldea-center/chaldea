import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/models/runtime_data.dart';
import 'package:chaldea/utils/http_override.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/icon_clipper.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../packages/app_info.dart';
import '../packages/method_channel/method_channel_chaldea.dart';
import '../packages/packages.dart';
import '../utils/json_helper.dart';
import 'gamedata/gamedata.dart';
import 'paths.dart';
import 'userdata/local_settings.dart';
import 'userdata/userdata.dart';

void _emptyCallback() {}

class _Database {
  // members
  final paths = PathManager();
  LocalSettings settings = LocalSettings();
  UserData userData = UserData();
  GameData gameData = GameData();
  RuntimeData runtimeData = RuntimeData();
  CacheManager cacheManager = CacheManager(Config('chaldea'));
  ItemCenter itemCenter = ItemCenter();

  // shortcut
  User get curUser => userData.users[userData.curUserKey];

  Map<int, SvtPlan> get curPlan => curUser.curPlan;
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

  void notifyDb({bool recalc = false}) {
    // TODO
  }

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

  // methods
  Future<void> initiate() async {
    await paths.initRootPath();
    await AppInfo.resolve(paths.appPath);
    MethodChannelChaldeaNext.configMethodChannel();

    if (kIsWeb) {
      setUrlStrategy(PathUrlStrategy());
      await FilePlus.initiate();
    } else {
      Hive.init(paths.hiveDir);
      HttpOverrides.global = CustomHttpOverrides();
    }
  }

  /// return the [UserData] instance, don't assign to [userData]
  Future<UserData?> loadUserData([String? fp]) async {
    return JsonHelper.loadModel<UserData?>(
      fp: fp ?? paths.userDataPath,
      fromJson: (data) => UserData.fromJson(data),
      onError: () => null,
    );
  }

  Future<LocalSettings> loadSettings([String? fp]) async {
    return settings = await JsonHelper.loadModel<LocalSettings>(
      fp: fp ?? paths.settingsPath,
      fromJson: (data) => LocalSettings.fromJson(data),
      onError: () => LocalSettings(),
    );
  }

  Future<void> saveAll() async {
    await saveUserData();
    await saveSettings();
  }

  Future<void> saveUserData() =>
      FilePlus(paths.userDataPath).writeAsString(jsonEncode(userData));

  Future<void> saveSettings() =>
      FilePlus(paths.settingsPath).writeAsString(jsonEncode(settings));

  Future<List<String>> backupUserdata(
      {bool disk = false, bool memory = true}) async {
    if (PlatformU.isWeb) return [];
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());

    List<String> _saved = [];
    final _lastSavedFile = FilePlus(paths.userDataPath);
    List<List<int>> objs = [
      if (disk && _lastSavedFile.existsSync())
        await _lastSavedFile.readAsBytes(),
      if (memory) utf8.encode(jsonEncode(userData)),
    ];
    for (var obj in objs) {
      String filename = timeStamp + (obj is FilePlus ? 'd' : 'm') + '.json';
      await FilePlus(joinPaths(paths.backupDir, filename)).writeAsBytes(obj);
      _saved.add(filename);
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
        isMCFile: false,
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
          cacheManager: cacheManager,
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
    return image;
  }
}

final db2 = _Database();
