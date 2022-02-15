import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pool/pool.dart';

import '../../models/models.dart';
import '../../packages/app_info.dart';
import '../../packages/file_plus/file_plus.dart';
import '../../packages/logger.dart';
import '../../packages/network.dart';
import '../../utils/basic.dart';
import '../../utils/json_helper.dart';

class GameDataLoader {
  final dio = Dio(BaseOptions(baseUrl: 'https://data.chaldea.center/'));

  // Dio get dio => Dio(BaseOptions(baseUrl: 'http://192.168.0.5:8002/'));

  GameDataLoader._();

  static GameDataLoader? instance;

  factory GameDataLoader() {
    return instance ??= GameDataLoader._();
  }

  Completer<GameData>? _completer;
  CancelToken? cancelToken;

  GameData? loadedGameData;
  Map<String, dynamic>? gameJson;

  double? get progress => _progress;
  double? _progress;

  dynamic error;

  Future<GameData> reload({
    ValueChanged<double>? onUpdate,
    bool offline = false,
    bool updateOnly = false,
    bool silent = false,
  }) async {
    assert(!(offline && updateOnly), [offline, updateOnly]);
    if (!offline && network.unavailable) {
      throw 'No network';
    }
    if (_completer != null && !_completer!.isCompleted) {
      return _completer!.future;
    }
    _completer = Completer();
    if (!updateOnly) gameJson = null;
    _progress = null;
    cancelToken = CancelToken();
    Future<void>.microtask(() => _loadJson(offline, onUpdate, updateOnly)
            .then((value) => _completer!.complete(loadedGameData = value)))
        .catchError((e, s) async {
      logger.e('load gamedata($offline)', e, s);
      error = e;
      _completer!.completeError(e, s);
    });
    gameJson = null;
    return _completer!.future;
  }

  Future<GameData> _loadJson(
      bool offline, ValueChanged<double>? onUpdate, bool updateOnly) async {
    final _versionFile = FilePlus(joinPaths(db2.paths.gameDir, 'version.json'));
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
        throw 'No version data found';
      }
      newVersion = oldVersion;
    } else {
      oldVersion ??= DataVersion();
      newVersion = DataVersion.fromJson((await dio.get('version.json')).data);
    }
    logger.d('fetch gamedata version: $newVersion');
    if (newVersion.appVersion > AppInfo.version) {
      throw 'Required app version: ≥ ${newVersion.appVersion.versionString}';
    }

    Map<String, dynamic> _gameJson = {};
    int finished = 0;
    Future<void> _downloadCheck(FileVersion fv,
        {String? l2mKey, dynamic Function(dynamic)? l2mFn}) async {
      final _file = FilePlus(joinPaths(db2.paths.gameDir, fv.filename));
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
          throw 'File ${fv.filename} not found or mismatched hash:'
              ' ${fv.hash} - $_localHash';
        }
        final resp = await dio.get(
          fv.filename,
          // cancelToken: cancelToken,
          options: Options(responseType: ResponseType.bytes),
        );
        final _hash = md5.convert(resp.data).toString().toLowerCase();
        if (!_hash.startsWith(fv.hash)) {
          throw 'Hash mismatch: ${fv.filename}: ${fv.hash} - $_hash';
        }
        _file.writeAsBytes(resp.data);
        bytes = resp.data;
      }
      if (updateOnly) return;
      dynamic fileJson = await JsonHelper.decodeBytes(bytes!);
      l2mFn ??= l2mKey == null ? null : (e) => e[l2mKey].toString();
      if (l2mFn != null) {
        assert(fileJson is List, '${fv.filename}: ${fileJson.runtimeType}');
        fileJson = Map.fromIterable(fileJson, key: l2mFn);
      }
      if (_gameJson[fv.key] == null) {
        _gameJson[fv.key] = fileJson;
      } else {
        final value = _gameJson[fv.key]!;
        if (value is Map) {
          value.addAll(fileJson);
        } else if (value is List) {
          value.addAll(fileJson);
        } else {
          throw 'Unsupported type: ${value.runtimeType}';
        }
      }
      print('loaded ${fv.filename}');
      finished += 1;
      _progress = finished / (newVersion.files.length + 0.1);
      onUpdate?.call(_progress!);
    }

    List<Future> futures = [];
    final _pool = Pool(offline ? 30 : 5);
    Map<String, String> keys = {
      'baseFunctions': 'funcId',
      'baseSkills': 'id',
      'bgms': 'id',
      'commandCodes': 'collectionNo',
      'craftEssences': 'collectionNo',
      'entities': 'id',
      'events': 'id',
      'exchangeTickets': 'key',
      'fixedDrops': 'key',
      'items': 'id',
      'mysticCodes': 'id',
      // 'questPhases':'',
      'servants': 'collectionNo',
      'summons': 'id',
      'wars': 'id',
    };

    for (final fv in newVersion.files.values) {
      String? l2mKey;
      dynamic Function(dynamic)? l2mFn;
      l2mKey = keys[fv.key];
      if (fv.key == 'questPhases') {
        l2mFn = (e) => (e['id'] * 10 + e['phase']).toString();
      }
      futures.add(_pool.withResource(
          () => _downloadCheck(fv, l2mKey: l2mKey, l2mFn: l2mFn)));
    }
    await Future.wait(futures);
    if (!offline) {
      _versionFile.writeAsString(jsonEncode(newVersion));
    }
    if (updateOnly) {
      if (newVersion.timestamp > oldVersion.timestamp) {
        db2.runtimeData.downloadedDataVersion = newVersion;
      }
      return GameData();
    } // bypass null
    gameJson = _gameJson;
    final _gamedata = GameData.fromJson(_gameJson);
    _gamedata.version = newVersion;
    _progress = finished / newVersion.files.length;
    onUpdate?.call(_progress!);
    return _gamedata;
  }
}
