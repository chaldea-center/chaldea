import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';

import '../../models/db.dart';
import '../../models/gamedata/gamedata.dart';
import '../../packages/app_info.dart';
import '../../packages/file_plus/file_plus.dart';
import '../../packages/logger.dart';
import '../../packages/network.dart';
import '../../utils/basic.dart';
import '../../utils/json_helper.dart';

class GameDataLoader {
  GameDataLoader._();

  static GameDataLoader? _instance;

  factory GameDataLoader() {
    return _instance ??= GameDataLoader._();
  }

  Future<GameData?> loadFromFile() async {
    var mapData = await JsonHelper.decodeFile(db2.paths.gameDataPath)
        .catchError((e) => Future.value());
    if (mapData == null) return null;
    GameData? gameData;
    try {
      gameData = GameData.fromMergedFile(Map.from(mapData));
      print('gamedata version(hive):'
          ' ${gameData.version.toJson()..remove('files')}');
      if (gameData.version.appVersion <= AppInfo.version) {
        return gameData;
      }
    } catch (e, s) {
      logger.e('fail to decode GameData', e, s);
    }
    return null;
  }

  Completer<Map<String, dynamic>>? _completer;
  CancelToken? cancelToken;

  Map<String, _DownloadProgress> progresses = {};

  bool get success =>
      progresses.isNotEmpty && progresses.values.every((e) => e.success);

  GameData? gameData;
  Map<String, dynamic>? gameDataMap;

  Future<GameData?> reloadAndMerge(
      {VoidCallback? onUpdate, bool offline = false}) async {
    try {
      gameData = GameData.fromMergedFile(
          await reload(onUpdate: onUpdate, offline: offline));
      if (gameDataMap != null) {
        FilePlus(db2.paths.gameDataPath)
            .writeAsString(jsonEncode(gameDataMap!));
      }
      return gameData;
    } catch (e, s) {
      logger.e('fail to reload&merge GameData', e, s);
      return null;
    }
  }

  Future<Map<String, dynamic>> reload(
      {VoidCallback? onUpdate, bool offline = false}) async {
    if (!offline && network.unavailable) {
      throw 'No network';
    }
    if (_completer != null && !_completer!.isCompleted) {
      return _completer!.future;
    }
    _completer = Completer();
    progresses.clear();
    cancelToken = CancelToken();
    Future<void>.microtask(() => _reload(onUpdate: onUpdate, offline: offline)
            .then((value) => _completer!.complete(gameDataMap = value)))
        .catchError(_completer!.completeError);
    return _completer!.future;
  }

  Future<Map<String, dynamic>> _reload(
      {VoidCallback? onUpdate, required bool offline}) async {
    onUpdate?.call();
    Map<String, dynamic> mapData = {};
    final dio = Dio(BaseOptions(baseUrl: 'https://data.chaldea.center/'));

    final versionFile = FilePlus(joinPaths(db2.paths.gameDir, 'version.json'));
    final DataVersion version;
    String? _versionPlain;
    if (offline) {
      version = DataVersion.fromJson(
          await JsonHelper.decodeBytes(await versionFile.readAsBytes()));
    } else {
      _versionPlain = (await dio.get('version.json',
              options: Options(responseType: ResponseType.plain)))
          .data;
      version = DataVersion.fromJson(jsonDecode(_versionPlain!));
    }
    mapData['version'] = version.toJson();
    logger.d('fetch gamedata version: ${version.toJson()..remove('files')}');
    if (version.appVersion > AppInfo.version) {
      throw 'Required app version: ≥ ${version.appVersion.versionString}';
    }

    Future<Uint8List> _checkAndDownload(_DownloadProgress dp) async {
      final file = FilePlus(joinPaths(db2.paths.gameDir, dp.file.filename));
      if (file.existsSync()) {
        final bytes = await file.readAsBytes();
        final hashCode = md5.convert(bytes).toString();
        if (hashCode.startsWith(dp.file.hash.toLowerCase())) {
          dp.cur = bytes.length;
          return bytes;
        }
      }
      final resp = await dio.get(
        dp.file.filename,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: cancelToken,
        onReceiveProgress: (cur, total) {
          dp.cur = cur;
          onUpdate?.call();
        },
      );
      final bytes = Uint8List.fromList(resp.data);
      final hashCode = md5.convert(bytes).toString();
      if (hashCode.startsWith(dp.file.hash.toLowerCase())) {
        file.writeAsBytes(bytes);
        return bytes;
      } else {
        throw 'mismatching hash value:\n${dp.file.hash}\n$hashCode';
      }
    }

    List<Future> futures = [];
    for (final fv in version.files.values) {
      // LicenseRegistry.licenses
      final dp = progresses[fv.filename] = _DownloadProgress(fv);
      futures.add(SchedulerBinding.instance!.scheduleTask(
        () => _checkAndDownload(dp).then((bytes) async {
          final contents = await JsonHelper.decodeBytes(bytes);
          if (contents is List) {
            List data = mapData.putIfAbsent(fv.key, () => []);
            data.addAll(contents);
          } else if (contents is Map<String, dynamic>) {
            Map<String, dynamic> data =
                mapData.putIfAbsent(fv.key, () => <String, dynamic>{});
            data.addAll(contents);
          } else {
            throw 'Unsupported data type: ${contents.runtimeType}';
          }
          dp.success = true;
          onUpdate?.call();
        }).catchError((e, s) async {
          dp.error = e;
          logger.e('download data file ${fv.filename} failed', e, s);
          onUpdate?.call();
        }),
        Priority.animation,
      ));
    }
    onUpdate?.call();
    await Future.wait(futures);
    onUpdate?.call();
    if (success) {
      if (!offline && _versionPlain != null) {
        await versionFile.writeAsString(_versionPlain);
      }
      await FilePlus(db2.paths.gameDataPath).writeAsString(jsonEncode(mapData));
      return gameDataMap = mapData;
    }
    throw 'some files failed';
  }
}

class _DownloadProgress {
  final FileVersion file;
  int cur = 0;
  bool success = false;
  dynamic error;

  _DownloadProgress(this.file);

  @override
  String toString() {
    return 'Download ${file.filename}: $cur/${file.size}, error=$error';
  }

  String? get errorDetail {
    if (error == null) return null;
    if (error is DioError) {
      final DioError _error = error;
      return _error.message.isEmpty
          ? _error.type.toString()
          : '${_error.type}: ${_error.message}';
    }
    return error.toString();
  }
}
