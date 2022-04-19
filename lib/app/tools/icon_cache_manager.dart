import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
  final IconCacheManager _manager = IconCacheManager();
  String progress = '...';

  void onProgress(int count, int total, int errors) {
    if (!mounted) return;
    setState(() {
      progress =
          '$count/$total (${(count / total * 100).toStringAsFixed(1)}%)\n'
          '$errors errors';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.icons),
      content: Text(
        'Limit: 10/second\n'
        'Progress:\n$progress',
        style: kMonoStyle,
      ),
      actions: [
        TextButton(
          onPressed: () {
            _manager.cancel();
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: _manager._running ? null : _startCaching,
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
    _manager.start(
      onProgress: onProgress,
      interval: const Duration(milliseconds: 200),
    );
    setState(() {});
  }
}

@protected
class IconCacheManager {
  final _limiter = RateLimiter();

  bool _running = false;

  Future<void> cancel() async {
    _limiter.cancelAll();
    _running = false;
  }

  Future start({
    Function(int count, int total, int errors)? onProgress,
    Duration interval = const Duration(milliseconds: 200),
  }) async {
    if (network.unavailable) {
      return;
    }
    if (kIsWeb) {
      return;
    }
    _running = true;
    Set<String?> _icons = {};
    for (final svt in db.gameData.servants.values) {
      _icons.add(svt.icon);
      _icons.add(svt.customIcon);
    }
    for (final ce in db.gameData.craftEssences.values) {
      _icons.add(ce.icon);
    }
    for (final cc in db.gameData.commandCodes.values) {
      _icons.add(cc.icon);
    }
    for (final skill in db.gameData.baseSkills.values) {
      _icons.add(skill.icon);
    }
    const aaPrefix = 'https://static.atlasacademy.io/';

    List<String> resolvedIcons = _icons
        .where((e) => e != null && e.isNotEmpty && e.startsWith(aaPrefix))
        .whereType<String>()
        .toList();
    int total = resolvedIcons.length;
    int errors = 0;
    int finished = 0;

    List<Future> tasks = [];
    final dio = Dio();

    for (int index = 0; index < resolvedIcons.length; index++) {
      String url = resolvedIcons[index];
      String fp = url.replaceAll(aaPrefix, db.paths.gameIconDir + '/');
      if (!await File(fp).exists()) {
        tasks.add(_limiter.limited<void>(() async {
          try {
            await dio.download(url, fp, deleteOnError: true);
            finished += 1;
          } catch (e) {
            errors += 1;
          }
          print('download icon: $url\n    -> $fp');
          if (onProgress != null) {
            onProgress(finished, total, errors);
          }
        }));
      } else {
        finished += 1;
        if (onProgress != null) {
          onProgress(finished, total, errors);
        }
      }
    }

    await Future.wait(tasks);
    _running = false;
  }
}
