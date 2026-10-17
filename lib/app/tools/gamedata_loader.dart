import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import 'package:pool/pool.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/packages/language.dart' show Language;
import 'package:chaldea/utils/utils.dart';

import '../../generated/l10n.dart';
import '../../models/gamedata/gamedata_sliced.dart';
import '../../models/models.dart';
import '../../packages/app_info.dart';
import '../../packages/file_plus/file_plus.dart';
import '../../packages/logger.dart';
import '../../packages/network.dart';
import '../../utils/json_helper.dart';
import '../../utils/task_observer.dart';

class GameDataLoader {
  // Dio get dio => Dio(BaseOptions(baseUrl: 'http://192.168.0.5:8002/'));

  GameDataLoader._();

  static GameDataLoader instance = GameDataLoader._();

  factory GameDataLoader() => instance;

  static final _loadZoneKey = Object();
  _LoadRun? _run;
  final _idleTmp = _GameLoadingTempData();

  // Bind cached entities to their load, including callbacks that outlive it.
  _GameLoadingTempData get tmp => (Zone.current[_loadZoneKey] as _LoadRun?)?.tmp ?? _idleTmp;
  CancelToken? get cancelToken => _run?.network;
  bool get loading => _run != null;

  final progress = ValueNotifier<double?>(null);
  final downloading = ValueNotifier<int>(0);
  final activity = ValueNotifier<int>(0);

  dynamic error;

  Future<void> interrupt() async {
    final run = _run;
    if (run == null) return;
    // Manual updates finish normally, even if a startup recovery joins them.
    if (run.automatic) run.requestCancellation();
    await run.future;
  }

  void _advance(_LoadRun run) {
    if (identical(_run, run) && !run.canceled) activity.value++;
  }

  Future<T> _phase<T>(_LoadRun run, String name, Future<T> Function() action, {String? detail}) {
    run.check();
    _advance(run);
    return TaskObserver.wall(
      name,
      () async {
        try {
          return await run.wait(action());
        } finally {
          _advance(run);
        }
      },
      phase: true,
      detail: detail,
    );
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

  /// Concurrent callers share the current load and its original policy.
  /// Only automatic loads have total network deadlines and allow recovery cancellation.
  Future<GameData?> reload({
    bool offline = false,
    bool silent = false,
    bool force = false,
    bool automatic = false,
    Duration? connectTimeout,
  }) {
    final current = _run;
    if (current != null) return current.future;
    final run = _run = _LoadRun(automatic: automatic);
    progress.value = null;
    downloading.value = 0;
    error = null;
    _advance(run);
    // Initialize shared workers outside the load zone to avoid retaining its data.
    final workerInitialization = !offline && network.unavailable && silent ? Future<void>.value() : JsonHelper.init();
    unawaited(
      runZoned(
        () => _reload(
          run,
          workerInitialization: workerInitialization,
          offline: offline,
          silent: silent,
          force: force,
          connectTimeout: connectTimeout,
        ),
        zoneValues: {_loadZoneKey: run},
      ),
    );
    return run.future;
  }

  Future<void> _reload(
    _LoadRun run, {
    required Future<void> workerInitialization,
    required bool offline,
    required bool silent,
    required bool force,
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

    run.tmp._enabled = true;
    final observation = TaskObserver.observeLoading();
    final loadSpan = TaskObserver.start(
      'gamedata.reload',
      phase: true,
      detail: 'offline=$offline automatic=${run.automatic}',
    );
    var failed = true;
    GameData? data;
    final previousEnums = ConstGameData.deprecatedEnums;
    try {
      if (!offline && network.unavailable && silent) {
        throw UpdateError(S.current.error_no_internet);
      }
      await _phase(run, 'gamedata.worker.init', () => run.workers.wait(workerInitialization));
      final result = await _loadJson(run, offline, force, connectTimeout, db.settings.filters.removeOldDataRegion);
      run.check();
      if (result.isValid) {
        data = result;
        failed = error != null;
      } else {
        logger.d(
          'Invalid game data: ${result.version.text(false)}, '
          '${result.servantsById.length} servants, ${result.items.length} items',
        );
        throw UpdateError("Invalid game data!");
      }
    } catch (e, s) {
      if (!run.canceled) {
        if (e is! UpdateError || !e.silent) {
          logger.e('load gamedata(offline=$offline)', e, s);
        }
        _showError(e);
      }
    } finally {
      // Finish writes before another load can reuse their paths.
      await run.drainWrites();
      run.tmp.reset();
      if (failed) ConstGameData.deprecatedEnums = previousEnums;
      loadSpan.finish(failed: failed);
      observation.finish();
      if (identical(_run, run)) {
        _run = null;
        if (run.canceled) {
          progress.value = null;
          downloading.value = 0;
        }
      }
      run.complete(run.canceled ? null : data);
    }
  }

  Future<GameData> _loadJson(
    _LoadRun run,
    bool offline,
    bool force,
    Duration? connectTimeout,
    Region? removeOldDataRegion,
  ) async {
    final _versionFile = FilePlus(joinPaths(db.paths.gameDir, 'version.json'));
    DataVersion? oldVersion;
    DataVersion newVersion;
    try {
      if (_versionFile.existsSync()) {
        final text = await _phase(run, 'gamedata.version.read', _versionFile.readAsString);
        oldVersion = TaskObserver.sync('gamedata.version.parse', () => DataVersion.fromJson(jsonDecode(text)));
      }
    } catch (e, s) {
      run.check();
      logger.e('read old version failed', e, s);
    }
    run.check();
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
      final response = await _phase(
        run,
        'gamedata.version.download',
        () => _downFile(
          run,
          'version.json',
          timeout: run.automatic ? connectTimeout ?? const Duration(seconds: 5) : null,
        ),
      );
      newVersion = TaskObserver.sync('gamedata.version.parse', () => DataVersion.fromJson(response.json()));
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
    // files staged in gameCacheDir, to be committed into gameDir after all files pass
    List<FileVersion> _stagedFiles = [];
    int finished = 0;
    Future<void> _downloadCheck(FileVersion fv, {String? l2mKey, dynamic Function(dynamic)? l2mFn}) async {
      final _file = FilePlus(joinPaths(db.paths.gameDir, fv.filename));
      final _cacheFile = FilePlus(joinPaths(db.paths.gameCacheDir, fv.filename));
      Uint8List? bytes;
      if (_file.existsSync()) {
        bytes = await _phase(run, 'gamedata.file.read', _file.readAsBytes, detail: fv.filename);
      }
      // tier 1: gameDir, either full or minified (size, hash) pair
      bool valid =
          bytes != null &&
          (!db.settings.network.checkDataHash ||
              await _phase(
                run,
                'gamedata.file.check',
                () => checkFileVersion(bytes!, fv, scope: run.workers),

                detail: fv.filename,
              ));
      if (!valid) {
        if (offline) {
          final _localHash = bytes == null ? '' : await run.wait(JsonHelper.md5Hex(bytes, scope: run.workers));
          throw S.current.file_not_found_or_mismatched_hash(fv.filename, fv.hash, _localHash);
        }
        // tier 2: staging cache, strict size+hash so interrupted updates can resume
        final cached = await _phase(
          run,
          'gamedata.file.cache_read',
          () => _readStagedFile(_cacheFile, fv, scope: run.workers),

          detail: fv.filename,
        );
        if (cached != null) {
          bytes = cached;
          _stagedFiles.add(fv);
        } else {
          downloading.value += 1;
          Duration? remaining = run.automatic ? const Duration(minutes: 10) : null;
          Future<Response<dynamic>> download({bool t = false}) async {
            final watch = Stopwatch()..start();
            try {
              return await _phase(
                run,
                'gamedata.file.download',
                () => _downFileWithRetry(
                  run,
                  fv.filename,
                  timeout: remaining,
                  options: Options(responseType: ResponseType.bytes),
                  t: t,
                ),
                detail: fv.filename,
              );
            } finally {
              if (remaining != null) remaining = remaining! - watch.elapsed;
            }
          }

          var resp = await download();
          if (db.settings.network.checkDataHash &&
              !await run.wait(checkFileVersion(resp.data, fv, scope: run.workers))) {
            resp = await download(t: true);
            if (!await run.wait(checkFileVersion(resp.data, fv, scope: run.workers))) {
              final _hash = await run.wait(JsonHelper.md5Hex(resp.data, scope: run.workers));
              throw S.current.file_not_found_or_mismatched_hash(fv.filename, fv.hash, _hash);
            }
          }
          bytes = resp.data;
          // persist to staging cache immediately, do NOT retain bytes in memory until commit
          await _phase(
            run,
            'gamedata.file.cache_write',
            () => run.write(() => _cacheFile.writeAsBytes(bytes!)),

            detail: fv.filename,
          );
          _stagedFiles.add(fv);
        }
      }
      dynamic fileJson = await _phase(
        run,
        'gamedata.file.decode',
        () => JsonHelper.decodeBytes(bytes!, scope: run.workers),

        detail: fv.filename,
      );
      l2mFn ??= l2mKey == null ? null : (e) => e[l2mKey].toString();
      if (l2mFn != null) {
        assert(fileJson is List, '${fv.filename}: ${fileJson.runtimeType}');
        fileJson = TaskObserver.sync(
          'gamedata.file.index',
          () => Map.fromIterable(fileJson, key: l2mFn),
          detail: fv.filename,
        );
      }
      TaskObserver.sync('gamedata.file.merge', () {
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
      }, detail: fv.filename);

      // print('loaded ${fv.filename}');
      await Future.delayed(Duration(milliseconds: 200));
      run.check();
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
      'gachas': 'id',
      'wiki.commandCodes': 'collectionNo',
      'wiki.craftEssences': 'collectionNo',
      'wiki.events': 'id',
      'wiki.servants': 'collectionNo',
      'wiki.summons': 'id',
      'wiki.wars': 'id',
    };

    for (final fv in newVersion.files.values) {
      dynamic Function(dynamic)? l2mFn;
      if (fv.key == 'questPhases') {
        l2mFn = (e) => (e['id'] * 100 + e['phase']).toString();
      }
      futures.add(_pool.withResource(() => _downloadCheck(fv, l2mKey: keys[fv.key], l2mFn: l2mFn)));
    }
    await _phase(run, 'gamedata.files', () => Future.wait(futures));
    _gameJson['gachas'] ??= _gameJson['mstGacha'] ?? {};

    if (!offline) {
      await _phase(run, 'gamedata.add_data', () => _addGameAdd(run, _gameJson));
    }
    await _phase(run, 'gamedata.mappings', () => _patchMappings(_gameJson));

    if (_gameJson.isEmpty) {
      throw Exception('No data loaded');
    }
    _gameJson["version"] = newVersion.toJson();
    if (db.settings.filters.spoilerRegion != Region.jp) {
      _gameJson['spoilerRegion'] = const RegionConverter().toJson(db.settings.filters.spoilerRegion);
    }
    _gameJson['removeOldDataRegion'] = removeOldDataRegion == null
        ? null
        : const RegionConverter().toJson(removeOldDataRegion);
    Map? deprecatedEnums = _gameJson['constData']?['deprecatedEnums'];
    if (deprecatedEnums != null && deprecatedEnums.isNotEmpty) {
      ConstGameData.deprecatedEnums = {
        for (final (k, v) in deprecatedEnums.items)
          k as String: {for (final (k2, v2) in (v as Map).items) k2 as String: (v2 as num).toInt()},
      };
    }

    tmp.gameJson = _gameJson;
    GameData _gamedata = await _phase(
      run,
      'gamedata.objectify',
      () => gameDataFromJsonSliced(
        _gameJson,
        checkpoint: () {
          run.check();
          _advance(run);
        },
      ),
    );
    await _phase(run, 'gamedata.fix', () => _fixGameData(_gamedata));
    if (!offline) {
      logger.t(
        '[${offline ? "offline" : "online"}]Updating dataset(${_gamedata.version.text(false)}): ${_stagedFiles.length} files updated',
      );
      // Defer recovery during commit; version.json written last does not make it atomic.
      run.check();
      run.committing = true;
      try {
        for (final fv in _stagedFiles) {
          if (kDebugMode) print('writing ${basename(fv.filename)}');
          await _phase(run, 'gamedata.file.commit', () => _commitStagedFile(run, fv), detail: fv.filename);
        }
        if (newVersion != oldVersion) {
          await _phase(
            run,
            'gamedata.version.write',
            () => run.write(() => _versionFile.writeAsBytes(utf8.encode(jsonEncode(newVersion)))),
          );
        }
      } finally {
        run.finishCommit();
      }
    }
    run.check();
    db.runtimeData.upgradableDataVersion = newVersion;
    progress.value = finished / newVersion.files.length;
    return _gamedata;
  }

  Future<void> _addGameAdd(_LoadRun run, Map<String, dynamic> gamedata) async {
    final addDataJson = gamedata['addData'] as Map?;
    if (addDataJson == null) return;

    final addData = GameDataAdd.fromJson(Map.from(addDataJson));
    bool accepting = true;
    List<Future> futures = [
      for (final svtId in addData.svts)
        AtlasApi.svt(svtId).then((svt) {
          if (!accepting || run.canceled || svt == null) return;
          (gamedata['servants'] as List?)?.add(svt.toJson());
        }),
      for (final ceId in addData.ces)
        AtlasApi.ce(ceId).then((ce) {
          if (!accepting || run.canceled || ce == null) return;
          (gamedata['craftEssences'] as List?)?.add(ce.toJson());
        }),
      for (final ccId in addData.ccs)
        AtlasApi.cc(ccId).then((cc) {
          if (!accepting || run.canceled || cc == null) return;
          (gamedata['commandCodes'] as List?)?.add(cc.toJson());
        }),
      for (final itemId in addData.items)
        AtlasApi.item(itemId).then((item) {
          if (!accepting || run.canceled || item == null) return;
          (gamedata['items'] as Map?)?[item.id.toString()] ??= item.toJson();
        }),
      for (final eventId in addData.events)
        AtlasApi.event(eventId).then((event) {
          if (!accepting || run.canceled || event == null) return;
          (gamedata['events'] as Map?)?[event.id.toString()] ??= event.toJson();
        }),
      for (final warId in addData.wars)
        AtlasApi.war(warId).then((war) {
          if (!accepting || run.canceled || war == null) return;
          (gamedata['wars'] as Map?)?[war.id.toString()] ??= war.toJson();
        }),
    ];
    try {
      final pending = Future.wait(futures);
      await run.wait(run.automatic ? pending.timeout(const Duration(seconds: 30)) : pending);
    } catch (e, s) {
      run.check();
      logger.e('fetch addData failed', e, s);
    } finally {
      accepting = false;
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

  /// Hashing large files is offloaded to a worker isolate (see JsonHelper).
  static Future<bool> checkHash(List<int> bytes, String hash, {JsonWorkerScope? scope}) async {
    return (await JsonHelper.md5Hex(bytes, scope: scope)).startsWith(hash.toLowerCase());
  }

  /// Accepts either the full or minified size/hash pair.
  static Future<bool> checkFileVersion(List<int> bytes, FileVersion fv, {JsonWorkerScope? scope}) async {
    if (bytes.length == fv.size && await checkHash(bytes, fv.hash, scope: scope)) {
      return true;
    }
    return bytes.length == fv.minSize && await checkHash(bytes, fv.minHash, scope: scope);
  }

  /// Reads verified staged data, or returns null so the caller can download it.
  static Future<Uint8List?> _readStagedFile(FilePlus file, FileVersion fv, {JsonWorkerScope? scope}) async {
    if (!file.existsSync()) return null;
    try {
      final bytes = await file.readAsBytes();
      if (!await checkFileVersion(bytes, fv, scope: scope)) return null;
      return bytes;
    } catch (e, s) {
      logger.e('read staged file failed: ${fv.filename}', e, s);
      return null;
    }
  }

  /// Re-verifies staged data before copying it into gameDir; invalid data stays cached.
  static Future<void> _commitStagedFile(_LoadRun run, FileVersion fv) async {
    final cacheFile = FilePlus(joinPaths(db.paths.gameCacheDir, fv.filename));
    final bytes = await _readStagedFile(cacheFile, fv, scope: run.workers);
    if (bytes == null) {
      throw UpdateError('Staged file corrupted: ${fv.filename}');
    }
    await run.write(() => FilePlus(joinPaths(db.paths.gameDir, fv.filename)).writeAsBytes(bytes));
  }

  static bool _isRetryableNetworkError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return code != null && code >= 500 && code < 600;
      case DioExceptionType.unknown:
        // SocketException (e.g. network switched mid-download) is wrapped as unknown
        return e.error is SocketException;
      default:
        return false;
    }
  }

  /// At most two attempts; automatic loads also bound network waits and retry delay.
  static Future<Response<T>> _downFileWithRetry<T>(
    _LoadRun run,
    String filename, {
    required Duration? timeout,
    Options? options,
    bool t = false,
  }) async {
    final watch = Stopwatch()..start();
    int attempts = 0;
    while (true) {
      run.check();
      try {
        return await _downFile<T>(
          run,
          filename,
          options: options,
          t: t,
          timeout: timeout == null ? null : timeout - watch.elapsed,
        );
      } on DioException catch (e) {
        run.check();
        attempts += 1;
        if (attempts >= 2 || !_isRetryableNetworkError(e)) rethrow;
        logger.w('download $filename failed (attempt $attempts/2), retrying: $e');
        await run.wait(Future<void>.delayed(const Duration(seconds: 1)));
      }
    }
  }

  static Future<Response<T>> _downFile<T>(
    _LoadRun run,
    String filename, {
    Options? options,
    bool t = false,
    required Duration? timeout,
  }) async {
    run.check();
    if (timeout != null && timeout <= Duration.zero) throw TimeoutException('Loading timed out.');
    String url = '${HostsX.dataHost}/$filename';
    if (t) {
      final uri = Uri.parse(url);
      url = uri.replace(queryParameters: {...uri.queryParameters, 't': DateTime.now().timestamp.toString()}).toString();
    }
    if (AppInfo.packageName.startsWith(utf8.decode(base64Decode('Y29tLmxkcy4=')))) {
      url = 'https://$filename';
    }
    final dio = DioE();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    // Only automatic loads have total deadlines; manual loads time out on inactivity.
    final token = CancelToken();
    unawaited(run.network.whenCancel.then((error) => token.cancel(error)));
    bool timedOut = false;
    final timer = timeout == null
        ? null
        : Timer(timeout, () {
            timedOut = true;
            token.cancel('Loading timed out.');
          });
    int received = 0;
    try {
      // this line for debug
      // if (!url.contains('version')) await Future.delayed(Duration(seconds: 80));
      return await dio.get<T>(
        url,
        options: options,
        cancelToken: token,
        onReceiveProgress: (count, total) {
          if (count > received && !run.canceled) {
            received = count;
            final loader = GameDataLoader.instance;
            loader._advance(run);
          }
        },
      );
    } catch (_) {
      if (timedOut) throw TimeoutException('Loading timed out: $url');
      rethrow;
    } finally {
      timer?.cancel();
      dio.close();
    }
  }
}

/// Per-load state; no deadlines apply to parsing or file I/O.
class _LoadRun {
  _LoadRun({required this.automatic});

  final bool automatic;
  Completer<GameData?>? _result = Completer<GameData?>();
  Future<GameData?> get future => _result!.future;
  final network = CancelToken();
  final workers = JsonWorkerScope();
  // Keep the pool alive for the entire load, including network and file-I/O waits.
  final _releaseWorkers = JsonHelper.retainWorkers();
  final tmp = _GameLoadingTempData();
  final _cancellation = Completer<void>();
  final _writes = <Future<void>>[];
  bool committing = false;
  bool _requested = false;
  bool _canceled = false;

  bool get canceled => _canceled;

  void check() {
    if (canceled) throw UpdateError('Loading canceled.', true);
  }

  void requestCancellation() {
    _requested = true;
    if (committing || canceled) return;
    _canceled = true;
    _cancellation.complete();
    network.cancel('Loading canceled.');
    workers.cancel();
  }

  void finishCommit() {
    committing = false;
    if (_requested) requestCancellation();
  }

  Future<T> wait<T>(Future<T> future) async {
    if (committing) return future;
    final value = await Future.any<T>([
      future,
      _cancellation.future.then<T>((_) => throw UpdateError('Loading canceled.', true)),
    ]);
    check();
    return value;
  }

  Future<T> write<T>(Future<T> Function() action) {
    check();
    final future = action();
    _writes.add(future.then<void>((_) {}, onError: (Object error, StackTrace stack) {}));
    return future;
  }

  Future<void> drainWrites() => Future.wait(_writes);

  void complete(GameData? data) {
    // Release listeners and results so surviving callbacks do not retain the dataset.
    if (!_cancellation.isCompleted) _cancellation.complete();
    workers.cancel(); // All submitted jobs have settled, or were explicitly canceled.
    network.cancel('Loading finished.');
    _writes.clear();
    final result = _result!;
    _result = null;
    _releaseWorkers();
    result.complete(data);
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
