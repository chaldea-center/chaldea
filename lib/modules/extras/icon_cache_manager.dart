import 'dart:async';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/rate_limiter.dart';

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
    if (!db.hasNetwork) {
      EasyLoading.showInfo(S.current.error_no_network);
      return;
    }
    _manager.start(
      onProgress: onProgress,
      interval: const Duration(milliseconds: 200),
    );
    setState(() {});
  }
}

class IconCacheManager {
  final _limiter =
      RateLimiter(maxCalls: 10, period: const Duration(seconds: 1));

  bool _running = false;

  Future<void> cancel() async {
    _limiter.cancelAll();
    _running = false;
  }

  Future start({
    Function(int count, int total, int errors)? onProgress,
    Duration interval = const Duration(milliseconds: 200),
  }) async {
    if (!db.hasNetwork) {
      return;
    }
    _running = true;
    Set<String?> _icons = {};
    for (final svt in db.gameData.servants.values) {
      _icons.add(svt.icon);
      _icons.add(svt.svtCoinIcon);
      for (final activeSkill in [...svt.activeSkills, ...svt.activeSkillsEn]) {
        for (final skill in activeSkill.skills) {
          _icons.add(skill.icon);
        }
      }
      for (final passive in [...svt.passiveSkills, ...svt.passiveSkillsEn]) {
        _icons.add(passive.icon);
      }
    }
    for (final ce in db.gameData.crafts.values) {
      _icons.addAll([
        ce.icon,
        ce.skillIcon,
        ...ce.eventIcons,
      ]);
    }
    for (final cc in db.gameData.cmdCodes.values) {
      _icons.addAll([
        cc.icon,
        cc.skillIcon,
      ]);
    }
    for (final mc in db.gameData.mysticCodes.values) {
      _icons.addAll([mc.icon1, mc.icon2, ...mc.skills.map((e) => e.icon)]);
    }
    for (final enemy in db.gameData.enemies.values) {
      _icons.add(enemy.icon);
    }
    _icons.addAll(db.gameData.icons.keys);

    List<String> resolvedIcons = _icons
        .where((e) =>
            e != null && e.isNotEmpty && !e.toLowerCase().startsWith('http'))
        .whereType<String>()
        .toList();
    int total = resolvedIcons.length;
    int errors = 0;
    int finished = 0;

    List<Future> tasks = [];

    for (int index = 0; index < resolvedIcons.length; index++) {
      String key = resolvedIcons[index];
      String cacheName = db.getIconFullKey(key) ?? key;
      String originName = db.gameData.icons[cacheName] ?? cacheName;
      String fp = join(db.paths.gameIconDir, cacheName);
      if (!await File(fp).exists()) {
        tasks.add(_limiter.limited(() async {
          final url = await WikiUtil.resolveFileUrl(originName, fp);
          if (url == null) {
            errors += 1;
          }
          finished += 1;
          print('download icon: $key -> $url');
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
