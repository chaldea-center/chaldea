import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TreeSizePage extends StatefulWidget {
  const TreeSizePage({super.key});

  @override
  State<TreeSizePage> createState() => _TreeSizePageState();
}

enum _SortType { name, size, modified }

class _TreeSizePageState extends State<TreeSizePage> {
  final basePath = db.paths.appPath;
  MyFileStat? cur;
  MyFileStat? rootStat;
  _SortType sortType = _SortType.name;
  bool reversed = false;

  Future<void> loadStat() async {
    try {
      EasyLoading.show(status: 'Loading...');
      rootStat = await _iter(Directory(basePath), null);
      cur = rootStat;
      EasyLoading.showSuccess('Loaded');
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('Load fs stat failed', e, s);
    }
    if (mounted) setState(() {});
  }

  Future<MyFileStat> _iter(FileSystemEntity entity, MyFileStat? parent) async {
    final rawStat = await entity.stat();
    final stat = MyFileStat(
      entity: entity,
      type: rawStat.type,
      size: rawStat.size,
      mode: rawStat.mode,
      changed: rawStat.changed,
      modified: rawStat.modified,
      accessed: rawStat.accessed,
      children: [],
      parent: parent,
    );

    if (entity is Directory) {
      await for (final child in entity.list()) {
        if (!mounted) break;
        stat.children.add(await _iter(child, stat));
      }
      stat.dirSize = rawStat.size + Maths.sum(stat.children.map((e) => e.getSize()));
    }
    return stat;
  }

  @override
  void initState() {
    super.initState();
    loadStat();
  }

  @override
  Widget build(BuildContext context) {
    var stats = cur?.children ?? [];
    final dirs = stats.where((e) => e.isDirectory).toList();
    final files = stats.where((e) => !e.isDirectory).toList();
    switch (sortType) {
      case _SortType.name:
        dirs.sort2((e) => e.entity.path, reversed: reversed);
        files.sort2((e) => e.entity.path, reversed: reversed);
      case _SortType.size:
        dirs.sort2((e) => -e.getSize(), reversed: reversed);
        files.sort2((e) => -e.getSize(), reversed: reversed);
      case _SortType.modified:
        dirs.sort2((e) => e.modified, reversed: reversed);
        files.sort2((e) => e.modified, reversed: reversed);
    }
    stats = [...dirs, ...files];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tree Size'),
        leading: BackButton(
          onPressed: () {
            router.showDialog(
              builder: (context) {
                return SimpleConfirmDialog(
                  title: const Text('Exit'),
                  onTapOk: () {
                    Navigator.maybePop(context);
                  },
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                sortType = _SortType.values[(sortType.index + 1) % _SortType.values.length];
              });
              EasyLoading.showToast(sortType.name);
            },
            icon: const Icon(Icons.sort_by_alpha),
          ),
          IconButton(onPressed: loadStat, icon: const Icon(Icons.replay)),
          IconButton(
            onPressed:
                rootStat == null
                    ? null
                    : () {
                      setState(() {
                        cur = rootStat;
                      });
                    },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Column(
        children: [
          if (cur == null) const ListTile(dense: true, title: Text('not loaded')),
          if (cur != null) buildOne(cur!, null),
          if (cur?.parent != null) buildOne(cur!.parent!, '..'),
          kDefaultDivider,
          Expanded(
            child: ListView.separated(
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final child = stats[index];
                return buildOne(child, null);
              },
              separatorBuilder: (_, _) => const Divider(indent: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOne(MyFileStat stat, String? overwriteName) {
    final childrenCount = stat.children.length;
    final dirCount = stat.children.where((e) => e.isDirectory).length;
    final fileCount = childrenCount - dirCount;
    final isDirectory = stat.isDirectory;
    return ListTile(
      dense: true,
      tileColor: stat == cur || stat == cur?.parent ? Theme.of(context).highlightColor : null,
      leading: isDirectory ? const Icon(Icons.folder) : const SizedBox.shrink(),
      title: Text(overwriteName ?? pathlib.basename(stat.entity.path)),
      subtitle: Text(
        isDirectory ? '${stat.getPrettySize()}, $dirCount folders, $fileCount files' : stat.getPrettySize(),
      ),
      trailing: isDirectory ? const Icon(Icons.keyboard_arrow_right) : null,
      onTap:
          isDirectory && stat != cur
              ? () {
                setState(() {
                  cur = stat;
                });
              }
              : null,
      onLongPress: () {
        SimpleConfirmDialog(
          title: const Text('Stat'),
          showCancel: false,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry
                  in {
                    'rawSize': stat.size,
                    'size': '${stat.getSize()} (${stat.getPrettySize()})',
                    'type': stat.type,
                    'path': stat.entity.path,
                    'changed': stat.changed.toString(),
                    'modified': stat.modified.toString(),
                  }.entries)
                ListTile(dense: true, title: Text(entry.key), subtitle: Text(entry.value.toString())),
            ],
          ),
        ).showDialog(context);
      },
    );
  }
}

class MyFileStat implements FileStat {
  final FileSystemEntity entity;
  @override
  final FileSystemEntityType type;
  @override
  final int size;
  @override
  final int mode;
  @override
  final DateTime changed;
  @override
  final DateTime modified;
  @override
  final DateTime accessed;

  int dirSize = 0;
  List<MyFileStat> children;
  MyFileStat? parent;

  bool get isDirectory => type == FileSystemEntityType.directory;

  int getSize() {
    if (isDirectory) return dirSize;
    return size;
  }

  String getPrettySize() {
    double size = getSize().toDouble();
    const int kStep = 1024;
    if (size < kStep) {
      return '${size.toInt()}B';
    }
    size /= kStep;
    if (size < kStep) {
      return '${_trim(size)}KB';
    }
    size /= kStep;
    if (size < kStep) {
      return '${_trim(size)}MB';
    }
    size /= kStep;
    if (size < kStep) {
      return '${_trim(size)}GB';
    }
    size /= kStep;
    return '${_trim(size)}TB';
  }

  static String _trim(double v) {
    String s = v.toStringAsFixed(1);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return s;
  }

  @override
  String modeString() => throw UnimplementedError();

  MyFileStat({
    required this.entity,
    required this.type,
    required this.size,
    // required this.dirSize,
    required this.mode,
    required this.changed,
    required this.modified,
    required this.accessed,
    required this.children,
    required this.parent,
  });
}
