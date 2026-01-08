import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as pathlib;

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';

@protected
class IconCacheManagePage extends StatefulWidget {
  IconCacheManagePage({super.key});

  @override
  _IconCacheManagePageState createState() => _IconCacheManagePageState();
}

class _IconCacheManagePageState extends State<IconCacheManagePage> {
  final _loader = AtlasIconLoader.i;
  final _limiter = RateLimiter(maxCalls: 20, period: const Duration(seconds: 2), raiseOnLimit: false);
  List<Future<String?>> tasks = [];
  bool canceled = false;

  int success = 0;
  int failed = 0;

  @override
  void dispose() {
    super.dispose();
    canceled = true;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = tasks.isEmpty ? '0' : (success / tasks.length * 100).toStringAsFixed(1);
    final finished = tasks.isNotEmpty && success + failed >= tasks.length;
    return AlertDialog(
      title: Text(S.current.icons),
      content: Text(
        'Limit: ${_limiter.maxCalls}/${_limiter.period.inSeconds} second\n'
        'Progress:\n$success/${tasks.length} ($ratio%)\n'
        '$failed failed',
        style: kMonoStyle,
      ),
      actions: [
        if (!finished)
          TextButton(
            onPressed: () {
              _limiter.cancelAll();
              Navigator.of(context).pop();
            },
            child: Text(S.current.cancel),
          ),
        if (!finished) TextButton(onPressed: tasks.isNotEmpty ? null : _startCaching, child: Text(S.current.download)),
        if (finished)
          TextButton(
            onPressed: () {
              _limiter.cancelAll();
              Navigator.of(context).pop();
            },
            child: Text(S.current.confirm),
          ),
      ],
    );
  }

  void _startCaching() {
    if (network.unavailable) {
      EasyLoading.showInfo(S.current.error_no_internet);
      return;
    }
    Set<String?> urls = {
      for (final svtClass in [...SvtClassX.regularAll, SvtClass.ALL, SvtClass.EXTRA, SvtClass.MIX])
        for (final rarity in [1, 3, 5]) svtClass.icon(rarity),
      for (final item in db.gameData.items.values) item.borderedIcon,
      for (final svt in db.gameData.servantsNoDup.values) svt.customIcon,
      for (final costume in db.gameData.costumes.values) costume.icon,
      for (final ce in db.gameData.craftEssences.values) ce.borderedIcon,
      for (final cc in db.gameData.commandCodes.values) cc.borderedIcon,
      for (final mc in db.gameData.mysticCodes.values) ...[mc.extraAssets.item.female, mc.extraAssets.item.male],
      for (final func in db.gameData.baseFunctions.values) ...[
        func.funcPopupIcon,
        for (final buff in func.buffs) buff.icon,
      ],
    };
    _loader._failed.clear();
    for (final url in urls) {
      if (url == null || url.isEmpty) continue;
      tasks.add(
        _loader
            .get(url, limiter: _limiter)
            .then((res) {
              if (res != null) {
                success += 1;
              } else {
                failed += 1;
              }
              return res;
            })
            .catchError((e) async {
              if (e is! RateLimitCancelError) {
                failed += 1;
                print('failed $url: ${escapeDioException(e)}');
              }
              return '';
            })
            .whenComplete(() {
              if (mounted) setState(() {});
            }),
      );
    }
    setState(() {});
  }
}

class AtlasIconLoader extends _CachedLoader<String, String> {
  AtlasIconLoader._();
  static final AtlasIconLoader i = AtlasIconLoader._();
  final _rateLimiter = RateLimiter(maxCalls: 20, period: const Duration(seconds: 1));
  final _fsLimiter = RateLimiter(maxCalls: 10, period: const Duration(milliseconds: 100));

  bool shouldCacheImage(String url, {bool Function(String url)? cacheCheck}) {
    if (kIsWeb) return false;
    if (Atlas.isAtlasAsset(url)) {
      if (!url.endsWith('.png') ||
          // url.contains('merged') ||
          url.endsWith('questboard_cap_closed.png')) {
        return false;
      }
      return true;
    } else {
      if (cacheCheck != null) {
        return cacheCheck(url);
      }
      return false;
    }
  }

  String proxyAssetUrl(String url) {
    return HostsX.proxy.atlasAsset && url.startsWith(Hosts0.kAtlasAssetHostGlobal)
        ? url.replaceFirst(Hosts0.kAtlasAssetHostGlobal, HostsX.atlasAssetHost)
        : url;
  }

  @override
  Future<String?> download(String url, {RateLimiter? limiter, bool allowWeb = false}) async {
    final localPath = atlasUrlToFp(url, allowWeb: allowWeb);
    if (HostsX.proxy.atlasAsset) {
      url = proxyAssetUrl(url);
    }
    if (localPath == null) return null;
    if (const <String>[
      '/questboard_cap14000.png', // Ordeal Call
      '/questboard_cap15000.png', // 終章
      '/questboard_cap16000.png', // ??? (After Part 2)
    ].any((e) => url.endsWith(e))) {
      return null;
    }

    limiter ??= _rateLimiter;

    if (kIsWeb) {
      return _webDownload(url, localPath, limiter);
    } else {
      return _ioDownload(url, localPath, limiter);
    }
  }

  final _rnd = Random();

  static final Map<String, DateTime> _outdatedFiles = {
    "class_b_7@2.png": DateTime.utc(2025, 10, 9),
    "class_s_7@2.png": DateTime.utc(2025, 10, 9),
    "class_g_7@2.png": DateTime.utc(2025, 10, 9),
  };

  Future<String?> _ioDownload(String url, String path, RateLimiter limiter) async {
    final file = File(path).absolute;
    if (await _fsLimiter.limited(() async {
      await Future.delayed(Duration(milliseconds: _rnd.nextInt(100)));
      final stat = await file.stat();
      if (stat.type == FileSystemEntityType.notFound || stat.size == 0) {
        return false;
      }
      final outdateTime = _outdatedFiles[pathlib.basename(file.path)];
      if (outdateTime != null && stat.modified.isBefore(outdateTime)) {
        return false;
      }
      return true;
    })) {
      return path;
    }
    final resp = await limiter.limited(
      () => _retry(() => DioE().get(url, options: Options(responseType: ResponseType.bytes))),
    );
    file.parent.createSync(recursive: true);
    await file.writeAsBytes(List.from(resp.data));
    if (PlatformU.isWindows) {
      logger.t('download file: $url');
    } else {
      print("download file: $url");
    }
    return path;
  }

  Future<Response<T>> _retry<T>(
    Future<Response<T>> Function() task, {
    int retryCount = 5,
    Duration duration = const Duration(seconds: 5),
  }) async {
    int count = 0;
    while (true) {
      try {
        return await task();
      } on DioException catch (e) {
        final uri = e.requestOptions.uri;
        if (e.response?.statusCode != 404) {
          logger.t('download error: ${e.type.name}(${e.response?.statusCode}) ${e.error}, uri=$uri');
        }
        if (_shouldRetry(e)) {
          count += 1;
          logger.t('retry download ($count/$retryCount): $uri');
          if (count <= retryCount) {
            await Future.delayed(duration * count);
            continue;
          } else {
            logger.t('failed after $count retries: $uri');
          }
        }
        rethrow;
      }
    }
  }

  bool _shouldRetry(DioException e) {
    final resp = e.response;
    if (resp != null) {
      if (resp.statusCode == 429) return true;
      return false;
    } else {
      final error = e.error;
      if (e.type == DioExceptionType.connectionError) return true;
      if (error is HandshakeException) return true;
      if (error is HttpException) return true;
      return false;
    }
  }

  Future<String?> _webDownload(String url, String path, RateLimiter limiter) async {
    final file = FilePlus(path);
    if (await _fsLimiter.limited(() async {
      if (!await file.exists()) {
        return false;
      }
      return (await file.readAsBytes()).isNotEmpty;
    })) {
      return path;
    }
    final resp = await limiter.limited(
      () => _retry(() => DioE().get(url, options: Options(responseType: ResponseType.bytes))),
    );
    await file.writeAsBytes(List.from(resp.data));
    print('download file: $url');
    return path;
  }

  Future<void> deleteFromDisk(String url) async {
    final fp = atlasUrlToFp(url, allowWeb: true);
    if (fp != null) {
      final file = FilePlus(fp);
      if (file.existsSync()) {
        await FilePlus(fp).deleteSafe();
      }
    }
    evict(url);
  }

  String? atlasUrlToFp(String url, {bool allowWeb = false}) {
    if (kIsWeb && !allowWeb) return null;
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;
    // in case non-ascii in path
    String baseFolder = joinPaths(db.paths.assetsDir, uri.host);
    for (final host in [
      HostsX.atlasAsset.kGlobal,
      HostsX.atlasAsset.kCN,
      HostsX.atlasAsset.global,
      HostsX.atlasAsset.cn,
    ]) {
      if (uri.host == Uri.tryParse(host)?.host) {
        baseFolder = db.paths.atlasAssetsDir;
        break;
      }
    }

    return pathlib.joinAll([baseFolder, ...uri.pathSegments.where((e) => e.isNotEmpty)]);
  }
}

class _FailureDetail {
  DateTime time;
  int? statusCode;
  Duration? retryAfter;

  _FailureDetail({required this.time, this.retryAfter, this.statusCode});

  bool get neverRetry => retryAfter == null || retryAfter!.inSeconds <= 0;
}

abstract class _CachedLoader<K, V> {
  final Map<K, Completer<V?>> _completers = {};
  final Map<K, V> _success = {};
  final Map<K, _FailureDetail> _failed = {};

  V? getCached(K key) {
    if (_success.containsKey(key)) return _success[key];
    return null;
  }

  void evict(K key) {
    _completers.remove(key);
    _success.remove(key);
    _failed.remove(key);
  }

  _FailureDetail? failReason(K key) {
    return _failed[key];
  }

  bool isFailed(K key) {
    final detail = _failed[key];
    if (detail != null) {
      if (detail.neverRetry) {
        return true;
      }
      return detail.time.add(detail.retryAfter!).isAfter(DateTime.now());
    }
    return false;
  }

  void clearFailed() {
    _failed.clear();
  }

  void clearAll() {
    _failed.clear();
    _success.clear();
    _completers.clear();
  }

  Future<V?> download(K key, {RateLimiter? limiter, bool allowWeb = false});

  Future<V?> get(K key, {RateLimiter? limiter, bool allowWeb = false}) async {
    if (!allowWeb && kIsWeb) {
      assert(() {
        throw FileSystemException("Web is not allowed: $key");
      }());
      return null;
    }
    if (_success.containsKey(key)) return _success[key];
    if (_completers.containsKey(key)) return _completers[key]?.future;
    if (isFailed(key)) return null;
    Completer<V?> _cmpl = Completer();
    download(key, limiter: limiter, allowWeb: allowWeb)
        .then<void>((value) {
          if (value != null) {
            _success[key] = value;
            _failed.remove(key);
          } else {
            _failed[key] = _FailureDetail(time: DateTime.now());
          }
          _cmpl.complete(value);
        })
        .catchError((e, s) {
          _cmpl.complete(null);
          if (e is RateLimitCancelError) return;
          if (e is DioException) {
            final code = e.response?.statusCode;
            if (code == 403 || code == 404) {
              _failed[key] ??= _FailureDetail(time: DateTime.now(), statusCode: code);
              return;
            }
            logger.e('_CachedLoader.download failed: $key, url=${e.requestOptions.uri}', e, s);
          } else {
            logger.e('_CachedLoader.download failed: $key', e, s);
          }

          final detail = _failed[key];
          if (detail == null) {
            _failed[key] = _FailureDetail(time: DateTime.now(), retryAfter: const Duration(seconds: 30));
          } else if (detail.neverRetry) {
            return;
          } else {
            detail.retryAfter = Duration(seconds: detail.retryAfter!.inSeconds * 2);
          }
        });
    _completers[key] = _cmpl;
    return _cmpl.future;
  }
}

@Deprecated('will raise error in debug mode')
@immutable
class MyCacheImage extends ImageProvider<MyCacheImage> {
  const MyCacheImage(this.url, {this.scale = 1.0});
  final String url;
  final double scale;

  @override
  Future<MyCacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MyCacheImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(MyCacheImage key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[ErrorDescription('Url: $url')],
    );
  }

  Future<ui.Codec> _loadAsync(MyCacheImage key, DecoderBufferCallback decode) async {
    assert(key == this);

    final localPath = await AtlasIconLoader.i.get(key.url);
    if (localPath == null) {
      // if (kDebugMode) {
      //   return decode(await ui.ImmutableBuffer.fromUint8List(kOnePixel));
      // }
      throw StateError('${key.url} cannot be cached to local');
    }
    final bytes = await File(localPath).readAsBytes();
    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$localPath is empty and cannot be loaded as an image.');
    }

    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MyCacheImage && other.url == url && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'MyCacheImage')}("$url", scale: $scale)';
}
