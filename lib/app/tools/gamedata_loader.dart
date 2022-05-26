import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pool/pool.dart';

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
    bool updateOnly = false,
    bool silent = false,
  }) async {
    assert(!(offline && updateOnly), [offline, updateOnly]);
    void _showError(Object? e) {
      error = escapeDioError(e);
      if (!silent) EasyLoading.showInfo(error);
    }

    if (network.unavailable) {
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
      final result = await _loadJson(offline, onUpdate, updateOnly);
      db.runtimeData.upgradableDataVersion = result.version;
      _completer!.complete(result);
    } catch (e, s) {
      if (e is! UpdateError) logger.e('load gamedata($offline)', e, s);
      error = escapeDioError(e);
      _showError(error);
      _completer!.complete(null);
    }
    tmp.clear();
    return _completer!.future;
  }

  Future<GameData> _loadJson(
      bool offline, ValueChanged<double>? onUpdate, bool updateOnly) async {
    final _versionFile = FilePlus(joinPaths(db.paths.gameDir, 'version.json'));
    DataVersion? oldVersion;
    DataVersion newVersion;
    try {
      oldVersion =
          DataVersion.fromJson(jsonDecode(await _versionFile.readAsString()));
    } catch (e) {
      print(e);
    }
    if (offline) {
      // if not exist, raise error
      if (oldVersion == null) {
        throw UpdateError(S.current.error_no_version_data_found);
      }
      newVersion = oldVersion;
    } else {
      oldVersion ??= DataVersion();
      newVersion = DataVersion.fromJson((await _dioGet('version.json')).json());
    }
    if (newVersion.appVersion > AppInfo.version) {
      final String versionString = newVersion.appVersion.versionString;
      throw UpdateError(S.current.error_required_app_version(versionString));
    }
    if (newVersion.timestamp <= db.gameData.version.timestamp) {
      throw UpdateError(S.current.update_already_latest);
    }

    Map<String, dynamic> _gameJson = {};
    Map<FilePlus, List<int>> _dataToWrite = {};
    _dataToWrite[_versionFile] = utf8.encode(jsonEncode(newVersion));
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
      if (_localHash == null || !_localHash.startsWith(fv.hash)) {
        if (offline) {
          throw S.current.file_not_found_or_mismatched_hash(
              fv.filename, fv.hash, _localHash ?? '');
        }
        final resp = await _dioGet(
          fv.filename,
          // cancelToken: cancelToken,
          options: Options(responseType: ResponseType.bytes),
        );
        final _hash =
            md5.convert(List.from(resp.data)).toString().toLowerCase();
        if (!_hash.startsWith(fv.hash)) {
          throw S.current
              .file_not_found_or_mismatched_hash(fv.filename, fv.hash, _hash);
        }
        _dataToWrite[_file] = List.from(resp.data);
        bytes = resp.data;
      }
      if (updateOnly) return;
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
    for (final entry in _dataToWrite.entries) {
      await entry.key.writeAsBytes(entry.value);
    }
    if (updateOnly) return db.gameData;

    tmp.clear();
    tmp.gameJson = _gameJson;
    final _gamedata = GameData.fromJson(_gameJson);
    tmp.clear();
    _gamedata.version = newVersion;
    _progress = finished / newVersion.files.length;
    (onUpdate ?? _onUpdate)?.call(_progress!);
    _onUpdate = null;
    return _gamedata;
  }

  static Future<Response<T>> _dioGet<T>(String filename,
      {Options? options}) async {
    final url = '${Hosts.kDataHostGlobal}/$filename',
        cnUrl = '${Hosts.kDataHostCN}/$filename';
    if (!db.settings.proxyServer) {
      return await Dio().get<T>(url, options: options);
    }
    try {
      Completer<Response<T>> _completer = Completer();
      Timer(const Duration(seconds: 4), () {
        if (!_completer.isCompleted) {
          _completer.completeError(TimeoutException('CF connection timeout'));
        }
      });
      scheduleMicrotask(() {
        Dio(BaseOptions(connectTimeout: 1000, receiveTimeout: 3000))
            .get<T>(url, options: options)
            .then<void>((value) => _completer.complete(value))
            .catchError(_completer.completeError);
      });
      return await _completer.future;
    } catch (e) {
      if (db.settings.proxyServer) {
        // print('download data from CN: $cnUrl');
        return await Dio().get<T>(cnUrl, options: options);
      }
      rethrow;
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
