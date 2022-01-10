import 'dart:io';

import 'package:chaldea/models/runtime_data.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/http_override.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive/hive.dart';

import '../packages/file_plus/file_plus.dart';
import '../packages/file_plus/file_plus_web.dart';
import '../packages/method_channel/method_channel_chaldea.dart';
import '../packages/network.dart';
import '../utils/json_helper.dart';
import 'gamedata/gamedata.dart';
import 'settings/local_settings.dart';
import 'settings/paths.dart';
import 'userdata/userdata.dart';

class _Database {
  // members
  final paths = PathManager();
  LocalSettings settings = LocalSettings();
  UserData userData = UserData();
  GameData gameData = GameData();
  RuntimeData runtimeData = RuntimeData();

  // singleton
  static final _instance = _Database._internal();

  factory _Database() => _instance;

  _Database._internal();

  // methods
  Future<void> initiate() async {
    await paths.initRootPath();
    if (kIsWeb) {
      setUrlStrategy(PathUrlStrategy());
      initWebFileSystem();
    } else {
      Hive.init(paths.configDir);
      HttpOverrides.global = CustomHttpOverrides();
    }
    MethodChannelChaldea.configMethodChannel();
    network.init();

    // settings = await JsonHelper.loadModel(
    //   fp: joinPaths(paths.configDir, 'settings.json'),
    //   fromJson: (data) => LocalSettings.fromJson(data),
    //   onError: () => LocalSettings(),
    // );
    // userData = await loadUserData() ?? UserData();
  }

  Future<UserData?> loadUserData([String? fp]) async {
    return JsonHelper.loadModel<UserData?>(
      fp: paths.userDataPath,
      fromJson: (data) => UserData.fromJson(data),
      onError: () => null,
    );
  }

  Future<GameData?> loadGameData([String? folder]) async {
    void _lapse(DateTime t0, msg) {
      print('$msg: ${DateTime.now().difference(t0).inMilliseconds} ms');
    }

    final t0 = DateTime.now();
    print('start reading: $t0');

    final baseFolder = folder ?? paths.gameDir;
    Map<String, dynamic> srcData = {};

    Future<dynamic> _readJson(String key, {String? fn, String? l2mKey}) async {
      final _t0 = DateTime.now();
      final fp = joinPaths(baseFolder, (fn ?? key) + '.json');
      final contents = await FilePlus(fp).readAsString();
      // _lapse(_t0, 'load   $key');
      dynamic decoded = await JsonHelper.decodeAsync(contents);
      _lapse(_t0, 'decode $key');

      if (l2mKey != null) {
        decoded = Map.fromIterable(decoded, key: (x) => x[l2mKey].toString());
      }
      _lapse(_t0, 'parsed $key');
      return srcData[key] = decoded;
    }

    // final a = [
    await Future.wait([
      _readJson('version'),
      _readJson('servants', l2mKey: 'collectionNo'),
      _readJson('craftEssences', fn: 'craft_essences', l2mKey: 'collectionNo'),
      _readJson('commandCodes', fn: 'command_codes', l2mKey: 'collectionNo'),
      _readJson('mysticCodes', fn: 'mystic_codes', l2mKey: 'id'),
      _readJson('events', l2mKey: 'id'),
      _readJson('wars', l2mKey: 'id'),
      _readJson('items', l2mKey: 'id'),
      _readJson('fixedDrops', fn: 'fixed_drops'),
      _readJson('extraData', fn: 'extra_data'),
      _readJson('exchangeTickets', fn: 'exchange_tickets', l2mKey: 'key'),
      _readJson('questPhases', fn: 'quest_phases'),
      _readJson('mappingData', fn: 'mapping_data'),
      _readJson('constData', fn: 'const_data'),
      _readJson('dropRateData', fn: 'drop_rate'),
    ]);
    // ];
    Stopwatch();
    print(
        'start parse: ${DateTime.now().difference(t0).inMilliseconds} ms lapsed');
    final gamedata = GameData.fromJson(srcData);
    print('ended parse: '
        '${DateTime.now().difference(t0).inMilliseconds} ms lapsed');
    return gamedata;
  }
}

final db2 = _Database();
