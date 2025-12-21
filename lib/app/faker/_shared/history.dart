import 'dart:convert';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as pathlib;

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/faker.dart';
import 'package:chaldea/models/faker/quiz/cat_mouse.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class _LocalHistoryData {
  final String key;
  final File file;

  bool loaded = false;
  FateTopLogin? resp;
  Object? error;

  _LocalHistoryData(this.key, this.file);

  void load() {
    loaded = true;
    try {
      resp = FateTopLogin.fromJson(jsonDecode(file.readAsStringSync()));
    } catch (e) {
      error = e;
    }
  }
}

class FakerHistoryViewer extends StatefulWidget {
  final FakerAgent agent;
  final List<File> localHistory;
  const FakerHistoryViewer({super.key, required this.agent, this.localHistory = const []});

  @override
  State<FakerHistoryViewer> createState() => _FakerHistoryViewerState();
}

class _FakerHistoryViewerState extends State<FakerHistoryViewer> {
  late final agent = widget.agent;

  late final bool isLocalHistoryMode = widget.localHistory.isNotEmpty;

  List<_LocalHistoryData> localHistory = [];
  List<String> keys = [];
  int _currentPage = 0;
  final int countPerPage = 20;

  final scrollController = ScrollController();

  String? getKeyFromFilename(String fp) {
    final m = RegExp(r'_\d+_+([^\d_].*?)$').firstMatch(pathlib.basenameWithoutExtension(fp));
    return m?.group(1);
  }

  @override
  void initState() {
    super.initState();
    if (widget.localHistory.isNotEmpty) {
      for (final file in widget.localHistory) {
        final key = getKeyFromFilename(file.path);
        if (key == null) continue;
        localHistory.add(_LocalHistoryData(key, file));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLocalHistoryMode ? "Local History (${localHistory.length})" : "History (${agent.network.history.length})",
        ),
        actions: [
          if (!isLocalHistoryMode)
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(Icons.replay),
            ),
          if (!isLocalHistoryMode)
            IconButton(
              onPressed: () {
                final history = agent.network.history;
                if (history.length > 5) {
                  history.removeRange(0, history.length - 5);
                } else {
                  history.clear();
                }
                setState(() {});
              },
              icon: const Icon(Icons.clear_all),
              tooltip: S.current.clear,
            ),
          if (!isLocalHistoryMode)
            IconButton(
              onPressed: () async {
                final confirm = await SimpleConfirmDialog(title: Text('Load local history')).showDialog(context);
                if (confirm != true) return;
                final dir = Directory(agent.network.fakerDir);
                final files = [
                  for (final file in dir.listSync(recursive: true))
                    if (file is File && file.path.endsWith('.json')) file,
                ];
                files.sort2((e) => e.path, reversed: true);
                if (files.isEmpty) {
                  EasyLoading.showInfo('No local history found');
                  return;
                }
                router.pushPage(FakerHistoryViewer(agent: agent, localHistory: files));
              },
              icon: Icon(Icons.storage),
            ),
        ],
      ),
      body: DefaultTextStyle.merge(
        overflow: TextOverflow.ellipsis,
        child: ListTileTheme.merge(
          minTileHeight: 24,
          dense: true,
          child: isLocalHistoryMode ? buildLocalHistory() : buildAgentHistory(),
        ),
      ),
    );
  }

  Widget buildAgentHistory() {
    final history = agent.network.history.toList();
    return ListView.separated(
      controller: scrollController,
      itemBuilder: (context, index) =>
          buildAgentRecord(context, history.length - 1 - index, history[history.length - 1 - index]),
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.transparent),
      itemCount: history.length,
    );
  }

  Widget buildLocalHistory() {
    int maxPage = (localHistory.length / countPerPage).ceil();
    if (maxPage < 1) maxPage = 1;
    final shownItems = localHistory.skip(countPerPage * _currentPage).take(countPerPage).toList();
    for (final item in shownItems) {
      if (!item.loaded) item.load();
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemBuilder: (context, index) {
              final item = shownItems[index];
              if (item.error != null) {
                return ListTile(subtitle: Text(item.error.toString()));
              }
              return buildLocalRecord(context, index, shownItems[index]);
            },
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.transparent),
            itemCount: shownItems.length,
          ),
        ),
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (_currentPage > 0) _currentPage -= 1;
                    });
                  },
                  child: Text(S.current.prev_page),
                ),
              ),
              Expanded(child: Center(child: Text('${_currentPage + 1}/$maxPage'))),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (_currentPage < maxPage - 1) {
                        _currentPage += 1;
                        scrollController.jumpTo(0);
                      }
                    });
                  },
                  child: Text(S.current.next_page),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLocalRecord(BuildContext context, int index, _LocalHistoryData record) {
    return buildRecord(context, index + countPerPage * _currentPage, record.key, record.resp, null);
  }

  Widget buildAgentRecord(BuildContext context, int index, FRequestRecord record) {
    return buildRecord(context, index, record.request?.key, record.response?.data, record);
  }

  Widget buildRecord(BuildContext context, int index, String? key, FateTopLogin? resp, FRequestRecord? record) {
    final serverTime = resp?.serverTime;
    final footerStyle = TextStyle(
      color: Theme.of(context).textTheme.bodySmall?.color,
      fontSize: 13.0,
      letterSpacing: -0.08,
    );
    return TileGroup(
      headerWidget: SHeader.rich(
        TextSpan(
          text: 'No.${index + 1}  ',
          children: [
            TextSpan(
              text: key?.trimChar("/") ?? '???',
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
      footerWidget: ListTile(
        minTileHeight: 8,
        title: record == null
            ? null
            : Text(
                [record.sendedAt, record.receivedAt].map((e) => e?.toTimeString(milliseconds: true)).join(' ~ '),
                style: footerStyle,
              ),
        trailing: serverTime == null ? null : Text('${serverTime.toTimeString()} (server)', style: footerStyle),
      ),
      children: [
        if (record != null) ...[buildRequestData(record.request?.rawRequest?.data), const Divider(height: 2)],
        if (resp?.responses.isNotEmpty == true) ...[
          ...?resp?.responses.map(buildFateResponse),
          const Divider(height: 2),
        ],
        ListTile(
          title: Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              _buildBadge(
                label: 'body',
                color: record?.response?.rawResponse == null ? Colors.grey : Colors.lightBlue,
                onTap: () {
                  final body = record?.response?.rawResponse.data;
                  router.pushPage(JsonViewerPage(body));
                },
              ),
              _buildBadge(
                label: 'master data',
                color: resp?.cache.isEmpty == true ? Colors.grey : Colors.blue,
                onTap: () => _onTapMasterData(resp),
              ),
            ],
          ),
          // trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () => _onTapMasterData(resp),
        ),
      ],
    );
  }

  Widget buildRequestData(dynamic data) {
    if (data == null) return const ListTile(title: Text('no data'));
    return ListTile(
      title: Text.rich(
        TextSpan(
          text: 'request: ',
          children: [
            TextSpan(
              text: data.toString(),
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        showRequestDataFormatDialog(context, data);
      },
    );
  }

  Widget buildFateResponse(FateResponseDetail detail) {
    Map? data;
    if (detail.isSuccess()) {
      data = detail.success;
      if (detail.nid == 'gamedata' && data != null) {
        data = {
          for (final (k, v) in data.items)
            k: const {'webview', 'assetbundle', 'master', 'assetbundleKey'}.contains(k) && v != ''
                ? '(${v.toString().length})${v.toString().substring2(0, 100)}...'
                : v,
        };
      }
      if (data?.isNotEmpty != true && detail.fail?.isNotEmpty == true) {
        data = detail.fail;
      }
    } else {
      data = detail.fail;
    }
    final label = StringBuffer(detail.nid.toString());
    final action = detail.fail?['action'];
    if (action != null) label.write('.$action');
    if (!detail.isSuccess()) label.write(' | ${detail.resCode}');
    return ListTile(
      title: Text.rich(
        TextSpan(
          children: [
            CenterWidgetSpan(
              child: _buildBadge(
                label: label.toString(),
                color: detail.isSuccess() ? Colors.green.shade700 : Colors.red,
              ),
            ),
            const TextSpan(text: '  '),
            TextSpan(text: data.toString()),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: data?.isNotEmpty != true
          ? null
          : () {
              router.pushPage(JsonViewerPage(data));
            },
    );
  }

  Widget _buildBadge({required String label, required Color color, VoidCallback? onTap}) {
    Widget child = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 8, 4),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
    if (onTap != null) {
      child = InkWell(onTap: onTap, child: child);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: color),
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: child,
    );
  }

  void _onTapMasterData(FateTopLogin? resp) {
    final cache = Map.from(resp?.cache ?? {});
    if (cache.isNotEmpty) {
      for (final key in ['deleted', 'replaced', 'updated']) {
        if (!cache.containsKey(key)) continue;
        cache[key] = sortDict(cache[key]);
      }
      router.pushPage(JsonViewerPage(cache));
    }
  }
}

String _decode(String s) {
  return Uri.decodeQueryComponent(s);
}

List<MapEntry<String, String>> _parseFormBody(String data) {
  List<MapEntry<String, String>> entries = [];
  for (final frag in data.split('&')) {
    final index = frag.indexOf('=');
    if (index < 0) {
      entries.add(MapEntry(_decode(frag), ''));
    } else {
      entries.add(MapEntry(_decode(frag.substring(0, index)), _decode(frag.substring(index + 1))));
    }
  }
  return entries;
}

Future<void> showRequestDataFormatDialog(BuildContext context, dynamic data) {
  List<MapEntry<String, String>>? formData;
  Object? jsonData; // list or map
  if (data is String) {
    try {
      formData = _parseFormBody(data);
    } catch (e) {
      //
    }
    try {
      jsonData = jsonDecode(data);
    } catch (e) {
      //
    }
  } else if (data is List || data is Map) {
    jsonData = data;
  } else {}

  return showDialog(
    context: context,
    useRootNavigator: false,
    builder: (context) {
      return ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: SimpleDialog(
          title: const Text("Choose Format"),
          children: [
            ListTile(
              title: const Text("Raw String"),
              onTap: () {
                Navigator.pop(context);
                router.pushPage(_StringViewer(data: data.toString()));
              },
            ),
            ListTile(
              enabled: formData != null,
              onTap: formData == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      router.pushPage(FormDataViewer(data: formData!));
                    },
              title: const Text("Form"),
            ),
            ListTile(
              enabled: jsonData != null,
              onTap: jsonData == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      router.pushPage(JsonViewerPage(jsonData));
                    },
              title: const Text("Json"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                copyToClipboard(data.toString(), toast: true);
              },
              title: Text(S.current.copy),
            ),
          ],
        ),
      );
    },
  );
}

T? _try<T>(T Function() compute) {
  try {
    return compute();
  } catch (e) {
    return null;
  }
}

Future<void> _showDataDecryptDialog(BuildContext context, String text) {
  String? base64Text = _try(() => utf8.decode(base64Decode(text)));
  Object? msgpackBase64Text = _try(() => CatMouseGame().decodeBase64Msgpack(text));
  Object? battleResult = _try(() => CatMouseGame().decryptBattleResult(text));

  return showDialog(
    context: context,
    useRootNavigator: false,
    builder: (context) {
      return ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: SimpleDialog(
          title: const Text("Decrypt?"),
          children: [
            if (base64Text != null)
              ListTile(
                title: const Text("Base64 String"),
                onTap: () {
                  Navigator.pop(context);
                  router.pushPage(_StringViewer(data: base64Text));
                },
              ),
            if (msgpackBase64Text != null)
              ListTile(
                title: const Text("msgpack+base64"),
                onTap: () {
                  Navigator.pop(context);
                  if (msgpackBase64Text is List || msgpackBase64Text is Map) {
                    router.pushPage(JsonViewerPage(msgpackBase64Text));
                  } else {
                    router.pushPage(_StringViewer(data: msgpackBase64Text.toString()));
                  }
                },
              ),
            if (battleResult != null)
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  router.pushPage(JsonViewerPage(battleResult));
                },
                title: const Text("Battle Result"),
              ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                copyToClipboard(text, toast: true);
              },
              title: Text(S.current.copy),
            ),
          ],
        ),
      );
    },
  );
}

class _StringViewer extends StatelessWidget {
  final String data;
  const _StringViewer({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw String'),
        actions: [
          IconButton(
            onPressed: () {
              copyToClipboard(data, toast: true);
            },
            icon: const Icon(Icons.copy),
            tooltip: S.current.copy,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SafeArea(
          child: InheritSelectionArea(
            child: Text(data, style: const TextStyle(fontSize: 14, fontFamily: kMonoFont)),
          ),
        ),
      ),
    );
  }
}

class FormDataViewer extends StatelessWidget {
  final List<MapEntry<String, String>> data;
  const FormDataViewer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: Table(
            border: TableBorder(
              horizontalInside: Divider.createBorderSide(context),
              verticalInside: Divider.createBorderSide(context),
            ),
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              for (final entry in data)
                TableRow(children: [buildCell(context, entry.key, false), buildCell(context, entry.value, true)]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCell(BuildContext context, String text, bool isValue) {
    return InkWell(
      onTap: () {
        bool isBase64 = false;
        if (isValue && text.isNotEmpty) {
          try {
            base64Decode(text);
            isBase64 = true;
          } catch (e) {
            //
          }
        }
        if (!isBase64) {
          copyToClipboard(text, toast: true);
          return;
        }
        _showDataDecryptDialog(context, text);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(text, style: const TextStyle(fontFamily: kMonoFont)),
      ),
    );
  }
}
