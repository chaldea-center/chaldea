import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import 'package:pool/pool.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/hosts.dart';
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
      error = 'manual interrupted';
    }
  }

  Future<GameData?> reloadAndUpdate({
    bool offline = false,
    bool silent = false,
  }) async {
    final data = await reload(offline: offline, silent: silent);
    if (data != null) {
      db.gameData = data;
      db.notifyAppUpdate();
      EasyLoading.showSuccess(S.current.update_msg_succuss);
    }
    return data;
  }

  Future<GameData?> reload({
    bool offline = false,
    bool silent = false,
    bool force = false,
  }) async {
    void _showError(Object? e) {
      error = escapeDioError(e);
      if (!silent) EasyLoading.showInfo(error);
    }

    if (!offline && network.unavailable) {
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
      final result = await _loadJson(offline, force);
      if (result.isValid) {
        if (!completer.isCompleted) completer.complete(result);
      } else {
        logger.d('Invalid game data: ${result.version.text(false)}, '
            '${result.servantsById.length} servants, ${result.items.length} items');
        throw UpdateError("Invalid game data!");
      }
    } catch (e, s) {
      if (e is! UpdateError) logger.e('load gamedata(offline=$offline)', e, s);
      _showError(e);
      if (!completer.isCompleted) completer.complete(null);
    }
    tmp.reset();
    return completer.future;
  }

  Future<GameData> _loadJson(bool offline, bool force) async {
    final _versionFile = FilePlus(joinPaths(db.paths.gameDir, 'version.json'));
    DataVersion? oldVersion;
    DataVersion newVersion;
    try {
      if (_versionFile.existsSync()) {
        oldVersion =
            DataVersion.fromJson(jsonDecode(await _versionFile.readAsString()));
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
    } else {
      oldVersion ??= DataVersion();
      newVersion =
          DataVersion.fromJson((await _downFile('version.json')).json());
    }
    if (!force) {
      if (newVersion.appVersion > AppInfo.version) {
        final String versionString = newVersion.appVersion.versionString;
        db.runtimeData.dataRequiredAppVer = newVersion.appVersion;
        throw UpdateError(S.current.error_required_app_version(versionString));
      }
      if (newVersion.timestamp <= db.gameData.version.timestamp &&
          db.gameData.servantsById.isNotEmpty &&
          db.gameData.items.isNotEmpty) {
        throw UpdateError(S.current.update_already_latest);
      }
    }
    Map<String, dynamic> _gameJson = {};
    Map<FilePlus, List<int>> _dataToWrite = {};
    int finished = 0;
    Future<void> _downloadCheck(FileVersion fv,
        {String? l2mKey, dynamic Function(dynamic)? l2mFn}) async {
      final _file = FilePlus(joinPaths(db.paths.gameDir, fv.filename));
      Uint8List? bytes;
      String? _localHash;
      if (_file.existsSync()) {
        bytes = await _file.readAsBytes();
      }
      if (bytes != null) {
        _localHash = md5.convert(bytes).toString().toLowerCase();
      }
      bool hashMismatch = _localHash == null ||
          (db.settings.checkDataHash && !_localHash.startsWith(fv.hash));
      if (hashMismatch) {
        if (offline) {
          throw S.current.file_not_found_or_mismatched_hash(
              fv.filename, fv.hash, _localHash ?? '');
        }
        downloading.value += 1;
        var resp = await _downFile(
          fv.filename,
          options: Options(responseType: ResponseType.bytes),
        );
        var _hash = md5.convert(List.from(resp.data)).toString().toLowerCase();
        if (db.settings.checkDataHash && !_hash.startsWith(fv.hash)) {
          resp = await _downFile(
            fv.filename,
            options: Options(responseType: ResponseType.bytes),
            t: true,
          );
          _hash = md5.convert(List.from(resp.data)).toString().toLowerCase();
          if (!_hash.startsWith(fv.hash)) {
            throw S.current
                .file_not_found_or_mismatched_hash(fv.filename, fv.hash, _hash);
          }
        }
        _dataToWrite[_file] = List.from(resp.data);
        bytes = resp.data;
      }
      String text = utf8.decode(bytes!);
      for (final key in kDWCharReplace.keys) {
        text = text.replaceAll(key, kDWCharReplace[key]!);
      }
      dynamic fileJson = await JsonHelper.decodeString(text);
      l2mFn ??= l2mKey == null ? null : (e) => e[l2mKey].toString();
      if (l2mFn != null) {
        assert(fileJson is List, '${fv.filename}: ${fileJson.runtimeType}');
        fileJson = Map.fromIterable(fileJson, key: l2mFn);
      }
      Map<dynamic, dynamic> targetJson = fv.key.startsWith('wiki.')
          ? _gameJson.putIfAbsent('wiki', () => {})
          : _gameJson;
      String key = fv.key.startsWith('wiki.') ? fv.key.substring(5) : fv.key;
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
      finished += 1;
      progress.value = finished / (newVersion.files.length + 0.1);
    }

    List<Future> futures = [];
    final _pool = Pool(offline ? 30 : 5);
    Map<String, String> keys = {
      'baseFunctions': 'funcId',
      'baseSkills': 'id',
      'baseTds': 'id',
      'bgms': 'id',
      'commandCodes': 'collectionNo',
      // constData
      'craftEssences': 'collectionNo',
      // dropRate
      'entities': 'id',
      'events': 'id',
      'exchangeTickets': 'id',
      'fixedDrops': 'id',
      'items': 'id',
      // mappingData
      // mappingPatch
      'mysticCodes': 'id',
      // 'questPhases':'',
      'servants': 'collectionNo',
      'wars': 'id',
      'extraMasterMission': 'id',
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
      futures.add(_pool.withResource(
          () => _downloadCheck(fv, l2mKey: keys[fv.key], l2mFn: l2mFn)));
    }
    await Future.wait(futures);
    _patchMappings(_gameJson);

    if (_gameJson.isEmpty) {
      throw Exception('No data loaded');
    }
    tmp.reset();
    _gameJson["version"] = newVersion.toJson();
    tmp.gameJson = _gameJson;
    GameData _gamedata = GameData.fromJson(_gameJson);
    if (!offline) {
      logger.i(
          'Updating dataset(${_gamedata.version.text(false)}): ${_dataToWrite.length} files updated');
      _dataToWrite[_versionFile] = utf8.encode(jsonEncode(newVersion));
      for (final entry in _dataToWrite.entries) {
        if (kDebugMode) print('writing ${basename(entry.key.path)}');
        await entry.key.writeAsBytes(entry.value);
      }
    }

    tmp.reset();
    db.runtimeData.upgradableDataVersion = newVersion;
    progress.value = finished / newVersion.files.length;
    return _gamedata;
  }

  void _patchMappings(Map<String, dynamic> gamedata) {
    final Map? data = gamedata['mappingData'],
        patches = gamedata['mappingPatch'];
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
  }

  static bool checkHash(List<int> bytes, String hash) {
    return md5
        .convert(bytes)
        .toString()
        .toLowerCase()
        .startsWith(hash.toLowerCase());
  }

  static Future<Response<T>> _downFile<T>(
    String filename, {
    Options? options,
    bool t = false,
  }) async {
    String url = '${Hosts.dataHost}/$filename';
    if (t) {
      final uri = Uri.parse(url);
      url = uri.replace(queryParameters: {
        ...uri.queryParameters,
        't': DateTime.now().timestamp.toString(),
      }).toString();
    }
    if (AppInfo.packageName
        .startsWith(utf8.decode(base64Decode('Y29tLmxkcy4=')))) {
      url = 'https://$filename';
    }
    return await DioE().get<T>(url, options: options);
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

  @Deprecated('unnecessary')
  Future<void> fetchNewCards({bool silent = false}) async {
    final info = await AtlasApi.regionInfo();
    final remoteTime = info?['timestamp'] as int?;
    if (remoteTime == null) {
      EasyLoading.showError(S.current.failed);
      return;
    } else if (db.gameData.version.timestamp > remoteTime) {
      EasyLoading.showInfo(S.current.update_already_latest);
      return;
    }

    List<Future> futures = [];
    int _addedItem = 0;
    futures.add(AtlasApi.niceItems(expireAfter: Duration.zero).then((items) {
      if (items == null) return;
      for (final item in items) {
        if (db.gameData.items.containsKey(item.id)) {
          continue;
        }
        db.gameData.items[item.id] = item;
        _addedItem += 1;
      }
    }));

    // svts
    int _addedSvt = 0;
    futures.add(AtlasApi.basicServants(expireAfter: Duration.zero)
        .then((servants) async {
      if (servants == null) return;
      for (final basicSvt in servants) {
        if (db.gameData.servantsNoDup.containsKey(basicSvt.collectionNo) ||
            basicSvt.collectionNo == 0 ||
            ![SvtType.normal, SvtType.enemyCollectionDetail]
                .contains(basicSvt.type)) {
          continue;
        }
        final svt = await AtlasApi.svt(basicSvt.id);
        if (svt == null) continue;
        db.gameData.servantsNoDup[svt.collectionNo] = svt;
        _addedSvt += 1;
      }
    }));

    int _addedCE = 0;
    futures.add(AtlasApi.basicCraftEssences(expireAfter: Duration.zero)
        .then((crafts) async {
      if (crafts == null) return;
      for (final basicCard in crafts) {
        if (db.gameData.craftEssences.containsKey(basicCard.collectionNo)) {
          continue;
        }
        final card = await AtlasApi.ce(basicCard.id);
        if (card == null) continue;
        db.gameData.craftEssences[card.collectionNo] = card;
        _addedCE += 1;
      }
    }));

    int _addedCC = 0;
    futures.add(AtlasApi.basicCommandCodes(expireAfter: Duration.zero)
        .then((codes) async {
      if (codes == null) return;
      for (final basicCard in codes) {
        if (db.gameData.commandCodes.containsKey(basicCard.collectionNo)) {
          continue;
        }
        final card = await AtlasApi.cc(basicCard.id);
        if (card == null) continue;
        db.gameData.commandCodes[card.collectionNo] = card;
        _addedCC += 1;
      }
    }));

    await Future.wait(futures);

    if (_addedItem + _addedSvt + _addedCE + _addedCC > 0) {
      db.gameData.preprocess();
      db.itemCenter.init();
      db.notifyAppUpdate();
      String msg = '${S.current.update}: ';
      msg += [
        if (_addedSvt > 0) '$_addedSvt ${S.current.servant}',
        if (_addedCE > 0) '$_addedCE ${S.current.craft_essence}',
        if (_addedCC > 0) '$_addedCC ${S.current.command_code}',
        if (_addedItem > 0) '$_addedItem ${S.current.item}',
      ].join(', ');
      if (!silent) EasyLoading.showSuccess(msg);
    } else {
      if (!silent) EasyLoading.showInfo(S.current.refresh_data_no_update);
    }
  }
}

class UpdateError extends Error {
  final String message;
  UpdateError([this.message = ""]);

  @override
  String toString() {
    return message;
  }
}

class _GameLoadingTempData {
  bool _enabled = false;
  Map<String, dynamic>? gameJson;
  final Map<int, Buff> _buffs = {};
  final Map<int, BaseFunction> _baseFuncs = {};
  final Map<int, BaseSkill> _baseSkills = {};
  final Map<int, BaseTd> _baseTds = {};

  void reset() {
    _enabled = false;
    gameJson?.clear();
    gameJson = null;
    _buffs.clear();
    _baseFuncs.clear();
    _baseSkills.clear();
    _baseTds.clear();
  }

  Buff getBuff(int id, Buff Function() ifAbsent) {
    if (_enabled) {
      return _buffs.putIfAbsent(id, ifAbsent);
    } else {
      return ifAbsent();
    }
  }

  BaseFunction getFunc(int id, BaseFunction Function() ifAbsent) {
    if (_enabled) {
      return _baseFuncs.putIfAbsent(id, ifAbsent);
    } else {
      return ifAbsent();
    }
  }

  BaseSkill getBaseSkill(int id, BaseSkill Function() ifAbsent) {
    if (_enabled) {
      return _baseSkills.putIfAbsent(id, ifAbsent);
    } else {
      return ifAbsent();
    }
  }

  BaseTd getBaseTd(int id, BaseTd Function() ifAbsent) {
    if (_enabled) {
      return _baseTds.putIfAbsent(id, ifAbsent);
    } else {
      return ifAbsent();
    }
  }
}
