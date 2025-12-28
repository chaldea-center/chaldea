import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class AdminToolsPage extends StatefulWidget {
  const AdminToolsPage({super.key});

  @override
  State<AdminToolsPage> createState() => _AdminToolsPageState();
}

class _AdminToolsPageState extends State<AdminToolsPage> {
  List<_ResponseData> responses = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Tools')),
      body: ListView(
        children: [
          TileGroup(
            header: 'Actions',
            children: [
              ListTile(dense: true, title: Text('DB GC'), onTap: () => callRequest('POST', '/api/v4/admin/db-gc')),
              ListTile(
                dense: true,
                title: Text('Chaldea Update'),
                onTap: () => callRequest('POST', '/webhook/check-chaldea-update'),
              ),
              ListTile(
                dense: true,
                title: Text('Neon Metrics'),
                onTap: () => callRequest('GET', '/api/v4/admin/neon-metrics'),
              ),
            ],
          ),
          TileGroup(
            header: "Atlas Academy",
            children: [
              ListTile(
                dense: true,
                title: Text('Reload api server'),
                subtitle: Text.rich(
                  TextSpan(
                    text: db.settings.secrets.atlasReloadKey.isEmpty
                        ? "Reload key not set"
                        : db.settings.secrets.atlasReloadKey,
                    children: [
                      CenterWidgetSpan(
                        child: IconButton(
                          onPressed: () {
                            InputCancelOkDialog(
                              title: 'Reload Key',
                              validate: (s) => s.length == 36 || s.isEmpty,
                              onSubmit: (s) {
                                db.settings.secrets.atlasReloadKey = s.trim();
                                if (mounted) setState(() {});
                              },
                            ).showDialog(context);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                ),
                enabled: db.settings.secrets.atlasReloadKey.isNotEmpty,
                trailing: IconButton(
                  onPressed: () {
                    final reloadKey = db.settings.secrets.atlasReloadKey;
                    if (reloadKey.isEmpty) return;
                    callRequest('POST', 'https://api.atlasacademy.io/hooks/reload-api', headers: {'Secret': reloadKey});
                  },
                  icon: Icon(Icons.send),
                ),
              ),
              ListTile(
                dense: true,
                title: Text('Update exports'),
                subtitle: Text.rich(
                  TextSpan(
                    text: db.settings.secrets.atlasExportKey.isEmpty
                        ? "Export key not set"
                        : db.settings.secrets.atlasExportKey,
                    children: [
                      CenterWidgetSpan(
                        child: IconButton(
                          onPressed: () {
                            InputCancelOkDialog(
                              title: 'Export Key',
                              validate: (s) => s.length == 36 || s.isEmpty,
                              onSubmit: (s) {
                                db.settings.secrets.atlasExportKey = s.trim();
                                if (mounted) setState(() {});
                              },
                            ).showDialog(context);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                ),
                enabled: db.settings.secrets.atlasExportKey.isNotEmpty,
                trailing: IconButton(
                  onPressed: () {
                    final exportKey = db.settings.secrets.atlasExportKey;
                    if (exportKey.isEmpty) return;
                    _RegionSelectDialog(
                      title: Text('Update exports'),
                      footer: SFooter('Update all regions to reload all pg tables (including new table)'),
                      onSelected: (regions) {
                        if (regions.isEmpty) return;
                        callRequest(
                          'POST',
                          'https://api.atlasacademy.io/$exportKey/update',
                          headers: {'Content-Type': 'application/json'},
                          data: {'ref': "refs/heads/${regions.map((e) => e.upper).join('&')}"},
                        );
                      },
                    ).showDialog(context);
                  },
                  icon: Icon(Icons.send),
                ),
              ),
              Center(
                child: Wrap(
                  alignment: .center,
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () {
                        callRequest(
                          'GET',
                          'https://api.atlasacademy.io/openapi.json',
                          getText: (response) {
                            Map info = _addTimeStr(Map.from(response.data["info"]!));
                            info.remove('description');
                            return JsonEncoder.withIndent('  ').convert(info);
                          },
                        );
                      },
                      child: Text('openapi'),
                    ),
                    FilledButton(
                      onPressed: () {
                        callRequest(
                          'GET',
                          'https://api.atlasacademy.io/info',
                          getText: (response) {
                            Map info = Map.from(response.data!).deepCopy();
                            info = {for (final (k, v) in info.items) k: _addTimeStr(v)};
                            return JsonEncoder.withIndent('  ').convert(info);
                          },
                        );
                      },
                      child: Text('info'),
                    ),
                    FilledButton(
                      onPressed: () {
                        _RegionSelectDialog(
                          onSelected: (regions) async {
                            for (final region in regions) {
                              await callRequest(
                                'GET',
                                'https://api.atlasacademy.io/raw/${region.upper}/info',
                                getText: (response) {
                                  final info = _addTimeStr(Map.from(response.data!).deepCopy());
                                  return JsonEncoder.withIndent('  ').convert(info);
                                },
                              );
                              await Future.delayed(Duration(seconds: 1));
                            }
                          },
                        ).showDialog(context);
                      },
                      child: Text('export.info'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (final resp in responses.reversed)
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      [
                        '${resp.response.statusCode} ${resp.response.requestOptions.method} ${resp.response.realUri}',
                        resp.createdAt.toStringShort(),
                        if (resp.response.requestOptions.data != null)
                          'request data=${resp.response.requestOptions.data}',
                      ].join('\n'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Divider(height: 4),
                    Text(resp.getFinalText()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<Response?> callRequest(
    String method,
    String url, {
    String? msg,
    Map<String, String>? headers,
    Object? data,
    String Function(Response response)? getText,
  }) async {
    final confirm = await SimpleConfirmDialog(
      title: Text(S.current.confirm),
      content: msg == null ? null : Text(msg),
    ).showDialog(context);
    if (confirm != true) return null;
    final resp = await showEasyLoading(() async {
      final options = ChaldeaWorkerApi.addAuthHeader(
        options: Options(validateStatus: (_) => true, method: method),
      );
      options.headers = {...?options.headers, ...?headers};
      return await ChaldeaWorkerApi.createDio().request(url, options: options, data: data);
    });
    responses.add(_ResponseData(response: resp, getText: getText));
    if (mounted) setState(() {});
    return resp;
  }

  Map _addTimeStr(Map data, {List<String> extraKeys = const []}) {
    Map result = {};
    for (final (k, v) in data.items) {
      result[k] = v;
      if ((k.toString().toLowerCase().contains('timestamp') || extraKeys.contains(k)) && v is int) {
        result['${k}_str'] = v.sec2date().toStringShort();
      }
    }
    return result;
  }
}

class _RegionSelectDialog extends StatefulWidget {
  final Widget? title;
  final Widget? footer;
  final ValueChanged<List<Region>> onSelected;
  const _RegionSelectDialog({required this.onSelected, this.title, this.footer});

  @override
  State<_RegionSelectDialog> createState() => __RegionSelectDialogState();
}

class __RegionSelectDialogState extends State<_RegionSelectDialog> {
  List<Region> regions = [];
  @override
  Widget build(BuildContext context) {
    return SimpleConfirmDialog(
      title: widget.title,
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final region in Region.values)
            CheckboxListTile(
              value: regions.contains(region),
              title: Text(region.upper),
              onChanged: (v) {
                if (regions.contains(region)) {
                  regions.remove(region);
                } else {
                  regions.add(region);
                }
                setState(() {});
              },
            ),
          ?widget.footer,
        ],
      ),
      onTapOk: () {
        widget.onSelected(regions);
      },
    );
  }
}

class _ResponseData {
  DateTime createdAt = DateTime.now();
  Response response;
  String Function(Response response)? getText;

  _ResponseData({required this.response, this.getText});

  String getFinalText() {
    if (getText != null) {
      try {
        return getText!(response);
      } catch (e, s) {
        logger.e('get response text failed', e, s);
      }
    }
    return response.data.toString().substring2(0, 2000);
  }
}
