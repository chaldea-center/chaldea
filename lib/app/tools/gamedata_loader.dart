import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import 'package:pool/pool.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/packages/language.dart' show Language;
import 'package:chaldea/utils/utils.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import '../../packages/app_info.dart';
import '../../packages/file_plus/file_plus.dart';
import '../../packages/logger.dart';
import '../../packages/network.dart';
import '../../utils/json_helper.dart';

class GameDataLoader {
  // Dio get dio => Dio(BaseOptions(baseUrl: 'http://192.168.0.5:8002/'));

  GameDataLoader._();

  static GameDataLoader instance = GameDataLoader._();

  factory GameDataLoader() => instance;

  Completer<GameData?>? _completer;
  CancelToken? cancelToken;

  _GameLoadingTempData tmp = _GameLoadingTempData();

  final progress = ValueNotifier<double?>(null);
  final downloading = ValueNotifier<int>(0);

  dynamic error;

  void interrupt() {
    if (_completer?.isCompleted == false) {
      _completer?.complete(null);
      progress.value = null;
      downloading.value = 0;
      error = 'manual interrupted';
    }
  }

  Future<GameData?> reloadAndUpdate({bool offline = false, bool silent = false}) async {
    final data = await reload(offline: offline, silent: silent);
    if (data != null) {
      db.gameData = data;
      db.notifyAppUpdate();
      EasyLoading.showSuccess(S.current.updated);
    }
    return data;
  }

  Future<GameData?> reload({
    bool offline = false,
    bool silent = false,
    bool force = false,
    Duration? connectTimeout,
  }) async {
    void _showError(Object? e) {
      error = escapeDioException(e);
      if (error.toString().contains('Out of Memory')) {
        final memory = AppInfo.totalRamInGB?.format(precision: 1);
        String hint = Language.isZH ? '设备运行内存不足(总${memory}GB)' : 'Device memory/RAM low(Total ${memory}GB)';
        error = '$hint\n$error';
      }
      if (!silent) {
        EasyLoading.showInfo(error);
      }
    }

    if (!offline && network.unavailable && silent) {
      _showError(S.current.error_no_internet);
      return null;
    }

    if (_completer != null && !_completer!.isCompleted) {
      return _completer!.future;
    }
    final completer = _completer = Completer();
    tmp.reset();
    tmp._enabled = true;
    progress.value = null;
    downloading.value = 0;
    error = null;
    cancelToken = CancelToken();
    try {
      final result = await _loadJson(offline, force, connectTimeout, db.settings.removeOldDataRegion);
      if (result.isValid) {
        if (!completer.isCompleted) completer.complete(result);
      } else {
        logger.d(
          'Invalid game data: ${result.version.text(false)}, '
          '${result.servantsById.length} servants, ${result.items.length} items',
        );
        throw UpdateError("Invalid game data!");
      }
    } catch (e, s) {
      if (e is! UpdateError || !e.silent) logger.e('load gamedata(offline=$offline)', e, s);
      _showError(e);
      if (!completer.isCompleted) completer.complete(null);
    } finally {
      tmp.reset();
    }
    return completer.future;
  }

  Future<GameData> _loadJson(bool offline, bool force, Duration? connectTimeout, Region? removeOldDataRegion) async {
    final _versionFile = FilePlus(joinPaths(db.paths.gameDir, 'version.json'));
    DataVersion? oldVersion;
    DataVersion newVersion;
    try {
      if (_versionFile.existsSync()) {
        oldVersion = DataVersion.fromJson(jsonDecode(await _versionFile.readAsString()));
      }
    } catch (e, s) {
      logger.e('read old version failed', e, s);
    }
    if (offline) {
      // if not exist, raise error
      if (oldVersion == null) {
        throw UpdateError(S.current.error_no_data_found);
      }
      newVersion = oldVersion;

      if (newVersion.timestamp < GameData.kMinCompatibleVer.timestamp) {
        throw UpdateError("Local data is outdated");
      }
    } else {
      oldVersion ??= DataVersion();
      newVersion = DataVersion.fromJson((await _downFile('version.json', timeout: connectTimeout)).json());
    }
    if (newVersion.appVersion > AppInfo.version) {
      final String versionString = newVersion.appVersion.versionString;
      db.runtimeData.dataRequiredAppVer = newVersion.appVersion;
      throw UpdateError(S.current.error_required_app_version(versionString, AppInfo.versionString));
    }
    if (!force) {
      if (newVersion.timestamp <= db.gameData.version.timestamp &&
          db.gameData.servantsById.isNotEmpty &&
          db.gameData.items.isNotEmpty) {
        throw UpdateError(S.current.update_already_latest, true);
      }
    }
    Map<String, dynamic> _gameJson = {};
    Map<FilePlus, List<int>> _dataToWrite = {};
    int finished = 0;
    Future<void> _downloadCheck(FileVersion fv, {String? l2mKey, dynamic Function(dynamic)? l2mFn}) async {
      final _file = FilePlus(joinPaths(db.paths.gameDir, fv.filename));
      Uint8List? bytes;
      String? _localHash;
      if (_file.existsSync()) {
        bytes = await _file.readAsBytes();
      }
      if (bytes != null) {
        _localHash = md5.convert(bytes).toString().toLowerCase();
      }
      bool hashMismatch = _localHash == null || (db.settings.checkDataHash && !_localHash.startsWith(fv.hash));
      if (hashMismatch) {
        if (offline) {
          throw S.current.file_not_found_or_mismatched_hash(fv.filename, fv.hash, _localHash ?? '');
        }
        downloading.value += 1;
        var resp = await _downFile(fv.filename, options: Options(responseType: ResponseType.bytes));
        var _hash = md5.convert(List.from(resp.data)).toString().toLowerCase();
        if (db.settings.checkDataHash && !_hash.startsWith(fv.hash)) {
          resp = await _downFile(fv.filename, options: Options(responseType: ResponseType.bytes), t: true);
          _hash = md5.convert(List.from(resp.data)).toString().toLowerCase();
          if (!_hash.startsWith(fv.hash)) {
            throw S.current.file_not_found_or_mismatched_hash(fv.filename, fv.hash, _hash);
          }
        }
        _dataToWrite[_file] = List.from(resp.data);
        bytes = resp.data;
      }
      String text = utf8.decode(bytes!);
      text = kReplaceDWChars(text);
      dynamic fileJson = await JsonHelper.decodeString(text);
      l2mFn ??= l2mKey == null ? null : (e) => e[l2mKey].toString();
      if (l2mFn != null) {
        assert(fileJson is List, '${fv.filename}: ${fileJson.runtimeType}');
        fileJson = Map.fromIterable(fileJson, key: l2mFn);
      }
      Map<dynamic, dynamic> targetJson = _gameJson;
      String key = fv.key;
      if (key.contains('.')) {
        final nodes = key.split('.');
        for (final node in nodes.sublist(0, nodes.length - 1)) {
          targetJson = targetJson.putIfAbsent(node, () => {});
        }
        key = nodes.last;
      }

      // Map<dynamic, dynamic> targetJson =
      //     fv.key.startsWith('wiki.') ? _gameJson.putIfAbsent('wiki', () => {}) : _gameJson;
      // String key = fv.key.startsWith('wiki.') ? fv.key.substring(5) : fv.key;
      if (targetJson[key] == null) {
        targetJson[key] = fileJson;
      } else {
        final value = targetJson[key]!;
        if (value is Map) {
          value.addAll(fileJson);
        } else if (value is List) {
          value.addAll(fileJson);
        } else {
          throw "Unsupported type: ${value.runtimeType}";
        }
      }

      // print('loaded ${fv.filename}');
      await Future.delayed(Duration(milliseconds: 200));
      finished += 1;
      progress.value = finished / (newVersion.files.length + 0.1);
    }

    List<Future> futures = [];
    final _pool = Pool(AppInfo.isDebugOn ? (offline ? 30 : 5) : (offline ? 5 : 3));
    Map<String, String> keys = {
      // keep list
      // 'servants': 'collectionNo',
      // 'craftEssences': 'collectionNo',
      // 'commandCodes': 'collectionNo',
      'items': 'id',
      'bgms': 'id',
      'entities': 'id',
      'baseFunctions': 'funcId',
      'baseSkills': 'id',
      'baseTds': 'id',
      // constData
      // dropRate
      'events': 'id',
      'campaigns': 'id',
      'classBoards': 'id',
      'grandGraphs': 'id',
      'enemyMasters': 'id',
      'exchangeTickets': 'id',
      'fixedDrops': 'id',
      // mappingData
      // mappingPatch
      'mysticCodes': 'id',
      // 'questPhases':'',
      'wars': 'id',
      'extraMasterMission': 'id',
      'masterMissions': 'id',
      'mstGacha': 'id',
      'gacha': 'id',
      'wiki.commandCodes': 'collectionNo',
      'wiki.craftEssences': 'collectionNo',
      'wiki.events': 'id',
      'wiki.servants': 'collectionNo',
      'wiki.summons': 'id',
      'wiki.wars': 'id',
      // 'wiki.webcrowMapping'
    };

    for (final fv in newVersion.files.values) {
      dynamic Function(dynamic)? l2mFn;
      if (fv.key == 'questPhases') {
        l2mFn = (e) => (e['id'] * 100 + e['phase']).toString();
      }
      futures.add(_pool.withResource(() => _downloadCheck(fv, l2mKey: keys[fv.key], l2mFn: l2mFn)));
    }
    await Future.wait(futures);
    _gameJson['gachas'] ??= _gameJson['mstGacha'] ?? {};

    await _addGameAdd(_gameJson);
    await _patchMappings(_gameJson);

    if (_gameJson.isEmpty) {
      throw Exception('No data loaded');
    }
    _gameJson["version"] = newVersion.toJson();
    if (db.settings.spoilerRegion != Region.jp) {
      _gameJson['spoilerRegion'] = const RegionConverter().toJson(db.settings.spoilerRegion);
    }
    _gameJson['removeOldDataRegion'] =
        removeOldDataRegion == null ? null : const RegionConverter().toJson(removeOldDataRegion);
    tmp.gameJson = _gameJson;
    GameData _gamedata = GameData.fromJson(_gameJson);
    await _fixGameData(_gamedata);
    if (!offline) {
      logger.t(
        '[${offline ? "offline" : "online"}]Updating dataset(${_gamedata.version.text(false)}): ${_dataToWrite.length} files updated',
      );
      if (newVersion != oldVersion) {
        _dataToWrite[_versionFile] = utf8.encode(jsonEncode(newVersion));
      }
      for (final entry in _dataToWrite.entries) {
        if (kDebugMode) print('writing ${basename(entry.key.path)}');
        await entry.key.writeAsBytes(entry.value);
      }
    }

    db.runtimeData.upgradableDataVersion = newVersion;
    progress.value = finished / newVersion.files.length;
    return _gamedata;
  }

  Future<void> _addGameAdd(Map<String, dynamic> gamedata) async {
    final addDataJson = gamedata['addData'] as Map?;
    if (addDataJson == null) return;

    final addData = GameDataAdd.fromJson(Map.from(addDataJson));
    List<Future> futures = [
      for (final svtId in addData.svts)
        AtlasApi.svt(svtId).then((svt) {
          if (svt == null) return;
          (gamedata['servants'] as List?)?.add(svt.toJson());
        }),
      for (final ceId in addData.ces)
        AtlasApi.ce(ceId).then((ce) {
          if (ce == null) return;
          (gamedata['craftEssences'] as List?)?.add(ce.toJson());
        }),
      for (final ccId in addData.ccs)
        AtlasApi.cc(ccId).then((cc) {
          if (cc == null) return;
          (gamedata['commandCodes'] as List?)?.add(cc.toJson());
        }),
      for (final itemId in addData.items)
        AtlasApi.item(itemId).then((item) {
          if (item == null) return;
          (gamedata['items'] as Map?)?[item.id.toString()] ??= item.toJson();
        }),
      for (final eventId in addData.events)
        AtlasApi.event(eventId).then((event) {
          if (event == null) return;
          (gamedata['events'] as Map?)?[event.id.toString()] ??= event.toJson();
        }),
      for (final warId in addData.wars)
        AtlasApi.war(warId).then((war) {
          if (war == null) return;
          (gamedata['wars'] as Map?)?[war.id.toString()] ??= war.toJson();
        }),
    ];
    try {
      await Future.wait(futures);
    } catch (e, s) {
      logger.e('fetch addData failed', e, s);
    }
  }

  Future<void> _patchMappings(Map<String, dynamic> gamedata) async {
    final Map? data = gamedata['mappingData'] ??= {}, patches = gamedata['mappingPatch'];
    if (data == null || patches == null) return;

    void _applyPatch(Map old, Map patch) {
      for (final key in patch.keys) {
        var vOld = old[key], vNew = patch[key];
        if (vOld == null && vNew != null) {
          old[key] = vNew;
        } else if (vOld is Map && vNew is Map) {
          _applyPatch(vOld, vNew);
        } else {
          old[key] = vNew;
        }
      }
    }

    _applyPatch(data, patches);

    // local dev patch
    if (kDebugMode && 1 > 2) {
      const files = <String>['buff_names', 'enums', 'event_trait', 'trait'];
      Map localPatches = {};
      await Future.wait(
        files.map((fn) async {
          final resp = await Dio().get(
            'http://127.0.0.1:5500/mappings/$fn.json',
            options: Options(responseType: ResponseType.plain),
          );
          localPatches[fn] = jsonDecode(resp.data as String);
        }).toList(),
      );
      _applyPatch(data, localPatches);
    }
  }

  Future<void> _fixGameData(GameData gamedata) async {
    const eventsToRemove = [71543, 71558];
    for (final eventId in eventsToRemove) {
      if (gamedata.events.containsKey(eventId)) {
        gamedata.events.remove(eventId);
      }
      if (gamedata.campaigns.containsKey(eventId)) {
        gamedata.campaigns.remove(eventId);
      }
    }

    if (!kDebugMode) return;
  }

  static bool checkHash(List<int> bytes, String hash) {
    return md5.convert(bytes).toString().toLowerCase().startsWith(hash.toLowerCase());
  }

  static Future<Response<T>> _downFile<T>(String filename, {Options? options, bool t = false, Duration? timeout}) {
    String url = '${HostsX.dataHost}/$filename';
    if (t) {
      final uri = Uri.parse(url);
      url = uri.replace(queryParameters: {...uri.queryParameters, 't': DateTime.now().timestamp.toString()}).toString();
    }
    if (AppInfo.packageName.startsWith(utf8.decode(base64Decode('Y29tLmxkcy4=')))) {
      url = 'https://$filename';
    }
    final future = DioE().get<T>(url, options: options);
    if (timeout != null) {
      return future.timeout(timeout);
    }
    return future;
    // try {
    //   Completer<Response<T>> _completer = Completer();
    //   Timer(const Duration(seconds: 4), () {
    //     if (!_completer.isCompleted) {
    //       _completer.completeError(TimeoutException('CF connection timeout'));
    //     }
    //   });
    //   scheduleMicrotask(() {
    //     Dio(BaseOptions(connectTimeout: 1000, receiveTimeout: 3000))
    //         .get<T>(url, options: options)
    //         .then<void>((value) => _completer.complete(value))
    //         .catchError(_completer.completeError);
    //   });
    //   return await _completer.future;
    // } catch (e) {
    //   if (db.settings.proxyServer) {
    //     // print('download data from CN: $cnUrl');
    //     return await Dio().get<T>(cnUrl, options: options);
    //   }
    //   rethrow;
    // }
  }
}

class UpdateError extends Error {
  final String message;
  final bool silent;
  UpdateError([this.message = "", this.silent = false]);

  @override
  String toString() {
    return message;
  }
}

/// remember to load these data file before others, change the order of `keys` in `_loadJson`
class _GameLoadingTempData {
  bool _enabled = false;
  Map<String, dynamic>? gameJson;
  final Map<Type, Map> _instances = {};

  bool get enabled => _enabled;

  void reset() {
    // logger.d('disable _GameLoadingTempData');
    _enabled = false;
    gameJson?.clear();
    gameJson = null;
    _instances.clear();
  }

  V _get<K, V>(K key, V Function() ifAbsent) {
    if (_enabled) {
      return _instances.putIfAbsent(V, () => <K, V>{}).putIfAbsent(key, ifAbsent);
      // return data.putIfAbsent(key, ifAbsent);
    } else {
      return ifAbsent();
    }
  }

  Item getItem(int id, Item Function() ifAbsent) => _get<int, Item>(id, ifAbsent);
  BgmEntity getBgm(int id, BgmEntity Function() ifAbsent) => _get<int, BgmEntity>(id, ifAbsent);
  BasicServant getBasicSvt(int id, BasicServant Function() ifAbsent) => _get<int, BasicServant>(id, ifAbsent);
  Buff getBuff(int id, Buff Function() ifAbsent) => _get<int, Buff>(id, ifAbsent);
  BaseFunction getFunc(int id, BaseFunction Function() ifAbsent) => _get<int, BaseFunction>(id, ifAbsent);
  BaseSkill getBaseSkill(int id, BaseSkill Function() ifAbsent) => _get<int, BaseSkill>(id, ifAbsent);
  BaseTd getBaseTd(int id, BaseTd Function() ifAbsent) => _get<int, BaseTd>(id, ifAbsent);
  SkillSvt getSkillSvt(String key, SkillSvt Function() ifAbsent) => _get<String, SkillSvt>(key, ifAbsent);
  TdSvt getTdSvt(String key, TdSvt Function() ifAbsent) => _get<String, TdSvt>(key, ifAbsent);
  EventMissionConditionDetail getMissionCondDetail(int id, EventMissionConditionDetail Function() ifAbsent) =>
      _get<int, EventMissionConditionDetail>(id, ifAbsent);
  List<Gift> getGifts(int id, List<Gift> Function() ifAbsent) => _get<int, List<Gift>>(id, ifAbsent);
}
