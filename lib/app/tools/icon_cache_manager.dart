import 'dart:async';
import 'dart:io';

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
  IconCacheManagePage({Key? key}) : super(key: key);

  @override
  _IconCacheManagePageState createState() => _IconCacheManagePageState();
}

class _IconCacheManagePageState extends State<IconCacheManagePage> {
  final _loader = AtlasIconLoader();
  final _limiter = RateLimiter(maxCalls: 5, raiseOnLimit: false);
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
    final ratio = (success / tasks.length * 100).toStringAsFixed(1);
    return AlertDialog(
      title: Text(S.current.icons),
      content: Text(
        'Limit: ${_limiter.maxCalls}/${_limiter.period.inSeconds} second\n'
        'Progress:\n$success/${tasks.length} ($ratio%)\n'
        '$failed failed',
        style: kMonoStyle,
      ),
      actions: [
        TextButton(
          onPressed: () {
            _limiter.cancelAll();
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: tasks.isNotEmpty ? null : _startCaching,
          child: Text(S.current.download),
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
      for (final svtClass in [
        ...SvtClassX.regularAllWithB2,
        SvtClass.ALL,
        SvtClass.EXTRA,
        SvtClass.MIX
      ])
        for (final rarity in [1, 3, 5]) svtClass.icon(rarity),
      for (final item in db.gameData.items.values) item.borderedIcon,
      for (final svt in db.gameData.servants.values) svt.customIcon,
      for (final costume in db.gameData.costumes.values) costume.icon,
      for (final ce in db.gameData.craftEssences.values) ce.borderedIcon,
      for (final cc in db.gameData.commandCodes.values) cc.borderedIcon,
      for (final mc in db.gameData.mysticCodes.values) ...[
        mc.extraAssets.item.female,
        mc.extraAssets.item.male,
      ],
    };
    for (final url in urls) {
      if (url == null || url.isEmpty) continue;
      tasks.add(_loader.download(url, limiter: _limiter).then((res) {
        print('downloaded $url -> $res');
        success += 1;
        return res;
      }).catchError((e) {
        if (e is! RateLimitCancelError) {
          failed += 1;
          print('failed $url: ${escapeDioError(e)}');
        }
        return '';
      }).whenComplete(() {
        if (mounted) setState(() {});
      }));
    }
    setState(() {});
  }
}

class AtlasIconLoader extends _CachedLoader<String, String> {
  AtlasIconLoader._();
  static AtlasIconLoader? _instance;
  factory AtlasIconLoader() => _instance ?? AtlasIconLoader._();

  @override
  final Duration failedExpire = const Duration(minutes: 30);

  final _rateLimiter = RateLimiter(maxCalls: 20);

  @override
  Future<String> download(String url, {RateLimiter? limiter}) async {
    final localPath = _atlasUrlToFp(url);
    if (await File(localPath).exists()) {
      return localPath;
    }
    final resp = await (limiter ?? _rateLimiter).limited(() =>
        Dio().get(url, options: Options(responseType: ResponseType.bytes)));
    File(localPath).createSync(recursive: true);
    await File(localPath).writeAsBytes(List.from(resp.data));
    print('download image: $url');
    return localPath;
  }

  String _atlasUrlToFp(String url) {
    assert(url.startsWith(Atlas.assetHost), url);
    String urlPath = url.replaceFirst(Atlas.assetHost, '');
    return pathlib.joinAll([
      db.paths.atlasIconDir,
      ...urlPath.split('/').where((e) => e.isNotEmpty)
    ]);
  }
}

abstract class _CachedLoader<K, V> {
  final Map<K, Completer<V?>> _completers = {};
  final Map<K, V> _success = {};
  final Map<K, DateTime> _failed = {};
  Duration get failedExpire;
  Future<V> download(K key);

  V? getCached(K key) {
    if (_success.containsKey(key)) return _success[key];
    return null;
  }

  bool isFailed(K key) {
    if (_failed[key] != null) {
      if (_failed[key]!.add(failedExpire).isBefore(DateTime.now())) {
        _failed.remove(key);
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  Future<V?> get(K key) async {
    if (_success.containsKey(key)) return _success[key];
    if (_completers.containsKey(key)) return _completers[key]?.future;
    if (isFailed(key)) return null;
    Completer<V?> _cmpl = Completer();
    download(key).then<void>((value) {
      _success[key] = value;
      _cmpl.complete(value);
    }).catchError((e, s) {
      logger.e('Got $key failed', e, s);
      _failed[key] = DateTime.now();
      _cmpl.complete(null);
    });
    _completers[key] = _cmpl;
    return _cmpl.future;
  }
}
