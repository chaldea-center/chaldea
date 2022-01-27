import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/json_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';

import '../../models/db.dart';
import '../../packages/app_info.dart';
import '../../packages/file_plus/file_plus.dart';

class GameDataLoader {
  GameDataLoader._();

  static GameDataLoader? _instance;

  factory GameDataLoader() {
    return _instance ??= GameDataLoader._();
  }

  Future<T> _withHive<T>(FutureOr<T> Function(Box box) callback) async {
    final _box = await Hive.openBox('gamedata-hive');
    final result = await callback(_box);
    await _box.close();
    return result;
  }

  Future<GameData?> loadFromHive() async {
    final data = await _withHive((box) => box.get('gamedata'));
    final gamedata = GameData.fromMergedFile(Map.from(data));
    print(
        'gamedata version(hive): ${gamedata.version.toJson()..remove('files')}');
    if (gamedata.version.appVersion <= AppInfo.version) {
      return db2.gameData = gamedata;
    }
  }

  Completer<Map<String, dynamic>>? _completer;
  CancelToken? cancelToken;

  Map<String, _DownloadProgress> progresses = {};

  bool get success =>
      progresses.isNotEmpty && progresses.values.every((e) => e.success);

  Map<String, dynamic>? gameDataMap;

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
            .then((value) => _completer!.complete(value)))
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
    if (offline) {
      version = DataVersion.fromJson(
          await JsonHelper.decodeBytesAsync(await versionFile.readAsBytes()));
    } else {
      version = DataVersion.fromJson((await dio.get('version.json')).data);
      await versionFile.writeAsString(jsonEncode(version));
    }
    mapData['version'] = version.toJson();
    logger.d('fetch gamedata version: ${version.toJson()..remove('files')}');
    // if (version.appVersion > AppInfo.version && !kDebugMode) {
    //   throw 'Required app version: ≥ ${version.appVersion.versionString}';
    // }

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
          final contents = await JsonHelper.decodeBytesAsync(bytes);
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
    if (kIsWeb) {
      Hive.box<Uint8List>('webfs').flush();
    }
    if (success) {
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
