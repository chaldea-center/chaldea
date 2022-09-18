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

  double? get progress => _progress;
  double? _progress;

  dynamic error;

  ValueChanged<double>? _onUpdate;
  void setOnUpdate(ValueChanged<double>? onUpdate) {
    _onUpdate = onUpdate;
    _onUpdate?.call(0);
  }

  Future<GameData?> reload({
    ValueChanged<double>? onUpdate,
    bool offline = false,
    bool silent = false,
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
    _completer = Completer();
    tmp.clear();
    _progress = null;
    error = null;
    cancelToken = CancelToken();
    try {
      final result = await _loadJson(offline, onUpdate);
      if (result.isValid) {
        _completer!.complete(result);
      } else {
        logger.d('Invalid game data: ${result.version.text(false)}, '
            '${result.servantsById.length} servants, ${result.items.length} items');
        throw UpdateError("Invalid game data!");
      }
    } catch (e, s) {
      if (e is! UpdateError) logger.e('load gamedata(offline=$offline)', e, s);
      _showError(e);
      _completer!.complete(null);
    }
    tmp.clear();
    return _completer!.future;
  }

  Future<GameData> _loadJson(
      bool offline, ValueChanged<double>? onUpdate) async {
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
    if (newVersion.appVersion > AppInfo.version) {
      final String versionString = newVersion.appVersion.versionString;
      throw UpdateError(S.current.error_required_app_version(versionString));
    }
    if (newVersion.timestamp <= db.gameData.version.timestamp &&
        db.gameData.servantsById.isNotEmpty &&
        db.gameData.items.isNotEmpty) {
      throw UpdateError(S.current.update_already_latest);
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

      dynamic fileJson = await JsonHelper.decodeBytes(bytes!);
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
      _progress = finished / (newVersion.files.length + 0.1);
      (onUpdate ?? _onUpdate)?.call(_progress!);
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
    if (_gameJson.isEmpty) {
      throw Exception('No data loaded');
    }
    tmp.clear();
    _gameJson["version"] = newVersion.toJson();
    tmp.gameJson = _gameJson;
    GameData _gamedata = GameData.fromJson(_gameJson);
    if (!offline) {
      logger.i(
          'Updating dataset(${_gamedata.version.text(false)}): ${_dataToWrite.length} files updated');
      _dataToWrite[_versionFile] = utf8.encode(jsonEncode(newVersion));
      for (final entry in _dataToWrite.entries) {
        print('writing ${basename(entry.key.path)}');
        await entry.key.writeAsBytes(entry.value);
      }
    }

    tmp.clear();
    db.runtimeData.upgradableDataVersion = newVersion;
    _progress = finished / newVersion.files.length;
    (onUpdate ?? _onUpdate)?.call(_progress!);
    _onUpdate = null;
    return _gamedata;
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
    String url = db.settings.proxyServer
        ? '${Hosts.kDataHostGlobal}/$filename'
        : '${Hosts.kDataHostCN}/$filename';
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

  Future<void> fetchUpdates() async {
    DataVersion dataVer;
    try {
      dataVer = DataVersion.fromJson(
          Map.from((await _downFile('version.json')).data));
    } catch (e, s) {
      EasyLoading.showError(escapeDioError(e));
      logger.e('fetch data version failed', e, s);
      return;
    }

    if (dataVer.timestamp > db.gameData.version.timestamp) {
      final newData = await reload();
      if (newData != null) {
        db.gameData = newData;
        db.notifyAppUpdate();
        EasyLoading.showSuccess(S.current.update_msg_succuss);
        return;
      } else {
        return;
      }
    }
    final info = await AtlasApi.regionInfo();
    final remoteTime = info?['timestamp'] as int?;
    if (remoteTime == null) {
      EasyLoading.showError(S.current.failed);
      return;
    } else if (db.gameData.version.timestamp > remoteTime) {
      EasyLoading.showInfo(S.current.update_already_latest);
      return;
    }
    final items = await AtlasApi.niceItems(expireAfter: Duration.zero) ?? [];
    int _addedItem = 0;
    for (final item in items) {
      if (db.gameData.items.containsKey(item.id)) {
        continue;
      }
      db.gameData.items[item.id] = item;
      _addedItem += 1;
    }

    // svts
    final servants =
        await AtlasApi.basicServants(expireAfter: Duration.zero) ?? [];
    int _addedSvt = 0;
    for (final basicSvt in servants) {
      if (db.gameData.servantsNoDup.containsKey(basicSvt.collectionNo)) {
        continue;
      }
      final svt = await AtlasApi.svt(basicSvt.id);
      if (svt == null) continue;
      db.gameData.servantsNoDup[svt.collectionNo] = svt;
      _addedSvt += 1;
    }

    final crafts =
        await AtlasApi.basicCraftEssences(expireAfter: Duration.zero) ?? [];
    int _addedCE = 0;
    for (final basicCard in crafts) {
      if (db.gameData.craftEssences.containsKey(basicCard.collectionNo)) {
        continue;
      }
      final card = await AtlasApi.ce(basicCard.id);
      if (card == null) continue;
      db.gameData.craftEssences[card.collectionNo] = card;
      _addedCE += 1;
    }

    final codes =
        await AtlasApi.basicCommandCodes(expireAfter: Duration.zero) ?? [];
    int _addedCC = 0;
    for (final basicCard in codes) {
      if (db.gameData.commandCodes.containsKey(basicCard.collectionNo)) {
        continue;
      }
      final card = await AtlasApi.cc(basicCard.id);
      if (card == null) continue;
      db.gameData.commandCodes[card.collectionNo] = card;
      _addedCC += 1;
    }

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
      EasyLoading.showSuccess(msg);
    } else {
      EasyLoading.showInfo(S.current.refresh_data_no_update);
    }
  }
}

class UpdateError extends Error {
  final String message;
  UpdateError([this.message = ""]);

  @override
  String toString() {
    return 'UpdateError: $message';
  }
}

class _GameLoadingTempData {
  Map<String, dynamic>? gameJson;
  Map<int, Buff> buffs = {};
  Map<int, BaseFunction> baseFuncs = {};
  Map<int, BaseSkill> baseSkills = {};
  Map<int, BaseTd> baseTds = {};

  void clear() {
    gameJson?.clear();
    gameJson = null;
    buffs.clear();
    baseFuncs.clear();
    baseSkills.clear();
    baseTds.clear();
  }
}
