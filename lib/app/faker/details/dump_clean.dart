import 'dart:convert';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as pathlib;

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/local_settings.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

class DumpRespCleanPage extends StatefulWidget {
  final String fakerBaseDir;
  final String fakerDir;
  const DumpRespCleanPage({super.key, required this.fakerBaseDir, required this.fakerDir});

  @override
  State<DumpRespCleanPage> createState() => _DumpRespCleanPageState();
}

class _FileGroup {
  final String key;
  final List<_FileInfo> files;
  int get totalSize => Maths.sum(files.map((e) => e.size));

  _FileGroup({required this.key, required this.files});
}

class _FileInfo {
  final File file;
  final String name;
  final String key;
  final DateTime? time;
  final int size;

  _FileInfo({required this.file, required this.name, required this.key, required this.time, required this.size});
}

enum _SortType { key, size, count }

class _DumpRespCleanPageState extends State<DumpRespCleanPage> {
  String listedFolder = '';
  Map<String, _FileGroup> fileGroups = {};
  _SortType sortType = _SortType.key;

  Future<void> loadData(String folderPath) async {
    try {
      if (!Directory(folderPath).existsSync()) {
        EasyLoading.showError('Directory not exist');
        return;
      }
      EasyLoading.show();
      final timeReg = RegExp(r'\d+');
      final keyReg = RegExp(r'^[\d_]+(.+)\.json$');
      fileGroups.clear();
      listedFolder = folderPath;
      await for (final file in Directory(folderPath).list()) {
        if (file is! File || !file.path.endsWith('.json')) continue;
        final name = pathlib.basename(file.path);
        final timeMatches = timeReg.allMatches(name).toList();
        DateTime? time;
        if (timeMatches.length >= 6) {
          final ns = timeMatches.map((e) => int.parse(e.group(0)!)).toList();
          time = DateTime(ns[0], ns[1], ns[2], ns[3], ns[4], ns[5], ns[6]);
        }
        final key = keyReg.firstMatch(name)?.group(1) ?? '_unknown';
        final stat = await file.stat();
        (fileGroups[key] ??= _FileGroup(
          key: key,
          files: [],
        )).files.add(_FileInfo(file: file, name: name, key: key, time: time, size: stat.size));
      }
      for (final group in fileGroups.values) {
        group.files.sort2((e) => e.time?.millisecondsSinceEpoch ?? 0);
      }
      if (mounted) setState(() {});
      EasyLoading.showSuccess(S.current.success);
    } catch (e, s) {
      logger.e('load dumps failed', e, s);
      print('error: $e');
      EasyLoading.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = fileGroups.values.toList();
    switch (sortType) {
      case _SortType.key:
        groups.sort2((e) => e.key);
      case _SortType.size:
        groups.sort2((e) => e.totalSize, reversed: true);
      case _SortType.count:
        groups.sort2((e) => e.files.length, reversed: true);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Dump Cleaner'),
        actions: [
          IconButton(
            onPressed: () => loadData(widget.fakerBaseDir),
            icon: Icon(Icons.filter_1),
            tooltip: 'Faker Base Dir',
          ),
          IconButton(onPressed: () => loadData(widget.fakerDir), icon: Icon(Icons.filter_2), tooltip: 'Faker Dir'),
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: FilterGroup<_SortType>(
              combined: true,
              padding: .zero,
              options: _SortType.values,
              values: FilterRadioData.nonnull(sortType),
              optionBuilder: (value) => Text(value.name),
              onFilterChanged: (v, _) {
                sortType = v.radioValue ?? sortType;
                if (mounted) setState(() {});
              },
            ),
          ),
          ListTile(
            dense: true,
            title: Text('${Maths.sum(fileGroups.values.map((e) => e.files.length))} files'),
            subtitle: Text(listedFolder),
          ),
          const Divider(),
          for (final group in groups)
            ListTile(
              title: Text(group.key),
              subtitle: Text(formatBytes(group.totalSize)),
              trailing: Text(group.files.length.toString()),
              enabled: group.files.isNotEmpty,
              onTap: () async {
                await router.pushPage(_DumpFileList(files: group.files));
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
    );
  }
}

class _DumpFileList extends StatefulWidget {
  final List<_FileInfo> files;
  const _DumpFileList({required this.files});

  @override
  State<_DumpFileList> createState() => _DumpFileListState();
}

class _DumpFileListState extends State<_DumpFileList> {
  late final List<_FileInfo> files = widget.files;
  int deletedCount = 0;

  Future<void> delete(_FileInfo file) async {
    await file.file.delete();
    files.remove(file);
    deletedCount += 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${files.length} files'),
        actions: [
          IconButton(
            onPressed: () async {
              await InputCancelOkDialog.number(
                title: 'Batch delete files',
                hintText: 'Max ${files.length}',
                validate: (v) => v > 0 && v <= files.length,
                onSubmit: (count) async {
                  try {
                    EasyLoading.show();
                    deletedCount = 0;
                    for (final file in files.toList()) {
                      if (deletedCount >= count) break;
                      await delete(file);
                      if (mounted) {
                        if (count < 100 || deletedCount % 10 == 0) {
                          setState(() {});
                        }
                      } else {
                        break;
                      }
                    }
                    if (mounted) setState(() {});
                    EasyLoading.showSuccess('Deleted $deletedCount files');
                  } catch (e, s) {
                    logger.e('batch delete dump file failed', e, s);
                    EasyLoading.showError(e.toString());
                  }
                },
              ).showDialog(context);
            },
            icon: Icon(Icons.clear_all),
            tooltip: 'Batch Delete',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return ListTile(
            dense: true,
            title: Text(file.time?.toStringShort() ?? 'Unknown'),
            subtitle: Text(file.name.replaceFirst('.json', '')),
            onTap: () async {
              try {
                final data = jsonDecode(await file.file.readAsString());
                router.pushPage(JsonViewerPage(data));
              } catch (e, s) {
                logger.e('decode dump file', e, s);
                EasyLoading.showError(e.toString());
              }
            },
            trailing: Wrap(
              children: [
                IconButton(
                  onPressed: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.delete),
                      content: Text(file.file.path),
                      onTapOk: () async {
                        try {
                          await delete(file);
                          if (mounted) setState(() {});
                          EasyLoading.showSuccess(S.current.delete);
                        } catch (e) {
                          EasyLoading.showError(e.toString());
                        }
                      },
                    ).showDialog(context);
                  },
                  icon: Icon(Icons.delete_forever),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
