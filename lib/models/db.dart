import 'dart:convert';
import 'dart:io';

import 'package:chaldea/models/runtime_data.dart';
import 'package:chaldea/utils/http_override.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive/hive.dart';

import '../packages/app_info.dart';
import '../packages/file_plus/file_plus.dart';
import '../packages/method_channel/method_channel_chaldea.dart';
import '../utils/json_helper.dart';
import 'gamedata/gamedata.dart';
import 'userdata/local_settings.dart';
import 'paths.dart';
import 'userdata/userdata.dart';

void _emptyCallback() {}

class _Database {
  // members
  final paths = PathManager();
  LocalSettings settings = LocalSettings();
  UserData userData = UserData();
  GameData gameData = GameData();
  RuntimeData runtimeData = RuntimeData();

  // shortcut
  User get curUser => userData.users[userData.curUserKey];

  // singleton
  static final _instance = _Database._internal();

  factory _Database() => _instance;

  _Database._internal();

  VoidCallback notifyAppUpdate = _emptyCallback;

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

  Future<void> saveData() async {
    await FilePlus(paths.userDataPath).writeAsString(jsonEncode(userData));
    await FilePlus(paths.settingsPath).writeAsString(jsonEncode(settings));
  }
}

final db2 = _Database();
