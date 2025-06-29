import 'dart:convert';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/jp/network.dart';
import 'package:chaldea/models/faker/quiz/cat_mouse.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FakerHistoryViewer extends StatefulWidget {
  final FakerAgent agent;
  const FakerHistoryViewer({super.key, required this.agent});

  @override
  State<FakerHistoryViewer> createState() => _FakerHistoryViewerState();
}

class _FakerHistoryViewerState extends State<FakerHistoryViewer> {
  late final agent = widget.agent;
  @override
  Widget build(BuildContext context) {
    final history = agent.network.history.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("History (${history.length})"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.replay),
          ),
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
        ],
      ),
      body: DefaultTextStyle.merge(
        overflow: TextOverflow.ellipsis,
        child: ListTileTheme.merge(
          minTileHeight: 24,
          dense: true,
          child: ListView.separated(
            itemBuilder: (context, index) =>
                buildOne(context, history.length - 1 - index, history[history.length - 1 - index]),
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.transparent),
            itemCount: history.length,
          ),
        ),
      ),
    );
  }

  Widget buildOne(BuildContext context, int index, FRequestRecord record) {
    final serverTime = record.response?.data.serverTime;
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
              text: record.request?.key.trimChar("/") ?? '???',
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
      footer: [record.sendedAt, record.receivedAt].map((e) => e?.toTimeString(milliseconds: true)).join(' ~ '),
      footerWidget: ListTile(
        minTileHeight: 8,
        title: Text(
          [record.sendedAt, record.receivedAt].map((e) => e?.toTimeString(milliseconds: true)).join(' ~ '),
          style: footerStyle,
        ),
        trailing: serverTime == null ? null : Text('${serverTime.toTimeString()} (server)', style: footerStyle),
      ),
      children: [
        buildRequestData(record.request?.rawRequest?.data),
        const Divider(height: 2),
        ...?record.response?.data.responses.map(buildFateResponse),
        const Divider(height: 2),
        ListTile(
          title: Container(
            alignment: AlignmentDirectional.centerStart,
            child: _buildBadge(label: 'master data', color: Colors.blue),
          ),
          // trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            final cache = Map.from(record.response?.data.cache ?? {});
            if (cache.isNotEmpty) {
              for (final key in ['deleted', 'replaced', 'updated']) {
                if (!cache.containsKey(key)) continue;
                cache[key] = sortDict(cache[key]);
              }
              router.pushPage(JsonViewerPage(cache));
            }
          },
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
                ? '(${v.toString().length})${v.toString().substring2(10)}...'
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

  Widget _buildBadge({required String label, required Color color}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: color),
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 8, 4),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
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
