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
          '${count + 1}/$total (${(count / total * 100).toStringAsFixed(1)}%)\n'
          '$errors errors';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.icons),
      content: Text(
        'Limit: 5 requests/second\n'
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
          onPressed: _manager.isCompleted
              ? () {
                  _manager.start(
                      onProgress: onProgress,
                      interval: const Duration(milliseconds: 200));
                  setState(() {});
                }
              : null,
          child: Text(S.current.download),
        ),
      ],
    );
  }
}

class IconCacheManager {
  bool _needCancel = false;
  Completer? _completer;

  Future? get future => _completer?.future;

  Future<void> cancel() async {
    _needCancel = true;
  }

  bool get isCompleted => _completer == null || _completer?.isCompleted == true;

  Future start(
      {Function(int count, int total, int errors)? onProgress,
      Duration interval = const Duration(milliseconds: 200)}) async {
    _completer = Completer();
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

    final limiter = RateLimiter(interval);

    for (int index = 0; index < resolvedIcons.length; index++) {
      if (_needCancel) {
        _completer?.complete();
        return;
      }
      String key = resolvedIcons[index];
      String cacheName = db.getIconFullKey(key) ?? key;
      String originName = db.gameData.icons[cacheName] ?? cacheName;
      String fp = join(db.paths.gameIconDir, cacheName);
      if (!await File(fp).exists()) {
        await limiter.call(() async {
          final url = await WikiUtil.resolveFileUrl(originName, fp);
          if (url == null) {
            errors += 1;
          }
          print('download icon: $key -> $url');
        });
      }
      if (onProgress != null) {
        onProgress(index, total, errors);
      }
    }
  }
}
