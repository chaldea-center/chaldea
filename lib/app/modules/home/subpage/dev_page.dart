import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/sharex.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class DevInfoPage extends StatefulWidget {
  const DevInfoPage({super.key});

  @override
  State<DevInfoPage> createState() => _DevInfoPageState();
}

class _DevInfoPageState extends State<DevInfoPage> {
  List<String> logNames = [];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      final dir = Directory(db.paths.logDir);
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          if (file is File && RegExp(r'\.log(\.\d+)?$').hasMatch(file.path)) {
            logNames.add(file.path);
          }
        }
      }
      logNames.sort();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        Widget _info(String title, dynamic value) {
          return ListTile(
            dense: true,
            title: Text(title),
            trailing: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: Text(
                value.toString(),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        return ListView(
          children: [
            TileGroup(
              header: 'App',
              children: [
                _info('UUID', AppInfo.uuid),
                if (!kIsWeb)
                  _info('Dart', Platform.version.split(' ').take(2).join(' ')),
                _info('OS',
                    '${PlatformU.operatingSystem} ${PlatformU.operatingSystemVersion}'),
                for (final key in AppInfo.appParams.keys)
                  _info(key, AppInfo.appParams[key].toString())
              ],
            ),
            TileGroup(
              header: 'Device',
              children: [
                for (final key in AppInfo.deviceParams.keys)
                  _info(key, AppInfo.deviceParams[key].toString())
              ],
            ),
            if (logNames.isNotEmpty)
              TileGroup(
                header: 'Logs',
                children: [
                  for (final log in logNames)
                    ListTile(
                      dense: true,
                      title: Text(pathlib.basename(log)),
                      onTap: () {
                        router.pushPage(_LogViewer(fp: log));
                      },
                    ),
                ],
              )
          ],
        );
      }),
    );
  }
}

class _LogViewer extends StatefulWidget {
  final String fp;
  const _LogViewer({required this.fp});

  @override
  State<_LogViewer> createState() => __LogViewerState();
}

class __LogViewerState extends State<_LogViewer> {
  final controller = ScrollController();
  List<String> lines = [];
  int page = -1;
  int get linesPerPage => 100;

  @override
  void initState() {
    super.initState();
    readLogs();
  }

  Future<void> readLogs() async {
    await Future.delayed(kSplitRouteDuration);
    final file = FilePlus(widget.fp);
    try {
      if (file.existsSync()) {
        final content = await file.readAsString();
        lines = LineSplitter.split(content)
            .map((e) => RegExp(r'^[└├┌└][-┄─]+$').hasMatch(e) ? ' ' : e)
            .toList();
      }
    } catch (e, s) {
      logger.e('read log file failed', e, s);
    }

    int maxPage = (lines.length / linesPerPage).floor();
    if (page == -1) page = maxPage;
    page = page.clamp(0, maxPage);
    if (mounted) setState(() {});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int start = page * linesPerPage, end = (page + 1) * linesPerPage;
    if (lines.isEmpty) lines.add('No content');
    start = start.clamp(0, lines.length - 1);
    end = end.clamp(start, lines.length);
    final shownText = lines.sublist(start, end).join('\n');
    return Scaffold(
      appBar: AppBar(
        title: Text(pathlib.basename(widget.fp)),
        actions: [
          if (kDebugMode)
            IconButton(onPressed: readLogs, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () {
              if (PlatformU.isDesktop) {
                openFile(pathlib.dirname(widget.fp));
              } else if (PlatformU.isMobile) {
                ShareX.shareFile(widget.fp);
              }
            },
            icon: const Icon(Icons.file_open),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                shownText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontFamily: kMonoFont),
              ),
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: SizedBox(
              height: 32,
              child: pagination(),
            ),
          )
        ],
      ),
    );
  }

  Widget pagination() {
    int count = (lines.length / linesPerPage).ceil();
    return Center(
      child: ListView(
        controller: controller,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          for (int index = 0; index < count; index++)
            SizedBox(
              width: 36,
              child: btn(index, count),
            ),
        ],
      ),
    );
  }

  Widget btn(int index, int count) {
    bool isActive = index == page;
    return MaterialButton(
      elevation: 1,
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      color: isActive
          ? Theme.of(context).primaryColor
          : Theme.of(context).canvasColor,
      onPressed: () {
        setState(() {
          page = index;
        });
      },
      child: Text(
        '${index + 1}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).hintColor,
        ),
      ),
    );
  }
}
