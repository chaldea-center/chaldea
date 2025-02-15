import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/remote_config.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  State<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _Group {
  final String title;
  final String globalUrl;
  final String cnUrl;
  final bool Function() getValue;
  final ValueChanged<bool> onChanged;
  _Group({
    required this.title,
    required this.globalUrl,
    required this.cnUrl,
    required this.getValue,
    required this.onChanged,
  });
}

class _NetworkSettingsPageState extends State<NetworkSettingsPage> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  Map<String, dynamic> testResults = {};

  final settings = db.settings.proxy;

  List<_Group> get testGroups => [
    _Group(
      title: 'Chaldea Data',
      globalUrl: '${HostsX.data.global}/version.json',
      cnUrl: '${HostsX.data.cn}/version.json',
      getValue: () => settings.data,
      onChanged: (v) => settings.data = v,
    ),
    _Group(
      title: '${S.current.chaldea_server}(Account/Laplace)',
      globalUrl: '${HostsX.worker.global}/network/ping',
      cnUrl: '${HostsX.worker.cn}/network/ping',
      getValue: () => settings.worker,
      onChanged: (v) => settings.worker = v,
    ),
    _Group(
      title: '${S.current.chaldea_server}(Recognizer)',
      globalUrl: '${HostsX.api.global}/network/ping',
      cnUrl: '${HostsX.api.cn}/network/ping',
      getValue: () => settings.api,
      onChanged: (v) => settings.api = v,
    ),
    _Group(
      title: 'Atlas Api',
      globalUrl: '${HostsX.atlasApi.global}/info',
      cnUrl: '${HostsX.atlasApi.cn}/info',
      getValue: () => settings.atlasApi,
      onChanged: (v) => settings.atlasApi = v,
    ),
    _Group(
      title: 'Atlas Assets',
      globalUrl: '${HostsX.atlasAsset.global}/JP/Script/Common/QuestStart.txt',
      cnUrl: '${HostsX.atlasAsset.cn}/JP/Script/Common/QuestStart.txt',
      getValue: () => settings.atlasAsset,
      onChanged: (v) => settings.atlasAsset = v,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.asBroadcastStream().listen((result) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final _connectivity = network.connectivity ?? [];
    const serverHint = SHeader(
      '对于大陆用户，若【Chaldea Data(应用数据)、Atlas Assets(图片等资源)】海外路线可正常使用，请尽量使用海外路线以节约流量费！\n'
      '若均无法下载资源，请选择海外节点并科学上网，电脑端可通过上述Host/Port设置代理。',
    );
    return Scaffold(
      appBar: AppBar(title: Text(S.current.network_settings)),
      body: ListTileTheme.merge(
        minLeadingWidth: 28,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // const SizedBox(height: 16),
            TileGroup(
              // footer: S.current.network_force_online_hint,
              children: [
                ListTile(
                  dense: true,
                  title: Text(S.current.network_status),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final result in _connectivity)
                        _textWithIndicator(result.name, result != ConnectivityResult.none),
                    ],
                  ),
                ),
                SwitchListTile.adaptive(
                  value: db.settings.forceOnline,
                  title: Text(S.current.network_force_online),
                  subtitle: Text(S.current.network_force_online_hint),
                  dense: true,
                  onChanged: (v) {
                    setState(() {
                      db.settings.forceOnline = v;
                    });
                  },
                ),
              ],
            ),
            if (!kIsWeb)
              TileGroup(
                header: 'Http(s) proxy',
                children: [
                  SwitchListTile.adaptive(
                    value: settings.enableHttpProxy,
                    title: Text(S.current.enable),
                    dense: true,
                    onChanged: (v) {
                      setState(() {
                        settings.enableHttpProxy = v;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Host'),
                    trailing: TextButton(
                      onPressed:
                          settings.enableHttpProxy
                              ? () {
                                InputCancelOkDialog(
                                  title: 'Host',
                                  text: settings.proxyHost,
                                  validate: (s) {
                                    if (s.isEmpty) return true;
                                    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)\.(\d+)$').firstMatch(s);
                                    if (m == null) return false;
                                    for (final index in [1, 2, 3, 4]) {
                                      final v = int.parse(m.group(index)!);
                                      if (v < 0 || v > 255) return false;
                                      if (index == 1 && v == 0) return false;
                                    }
                                    return true;
                                  },
                                  onSubmit: (s) {
                                    settings.proxyHost = s.isEmpty ? null : s;
                                    if (mounted) setState(() {});
                                  },
                                ).showDialog(context);
                              }
                              : null,
                      child: Text(settings.proxyHost ?? 'not set'),
                    ),
                  ),
                  ListTile(
                    title: const Text('Port'),
                    trailing: TextButton(
                      onPressed:
                          settings.enableHttpProxy
                              ? () {
                                InputCancelOkDialog(
                                  title: 'Port',
                                  text: settings.proxyPort?.toString(),
                                  validate: (s) {
                                    if (s.isEmpty) return true;
                                    final v = int.tryParse(s);
                                    if (v == null) return false;
                                    return v >= 1 && v <= 65535;
                                  },
                                  onSubmit: (s) {
                                    settings.proxyPort = s.isEmpty ? null : int.tryParse(s);
                                    if (mounted) setState(() {});
                                  },
                                ).showDialog(context);
                              }
                              : null,
                      child: Text(settings.proxyPort?.toString() ?? 'not set'),
                    ),
                  ),
                ],
              ),
            // const Divider(height: 8),
            const SizedBox(height: 8),
            Center(child: ElevatedButton(onPressed: _testNetwork, child: Text(S.current.test.toUpperCase()))),
            if (Language.isCHS) serverHint,
            for (final group in testGroups) _buildGroup(group),
            SafeArea(child: Language.isCHS ? serverHint : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(_Group group) {
    return TileGroup(
      header: group.title,
      children:
          [false, true].map((v) {
            final url = v ? group.cnUrl : group.globalUrl;
            return RadioListTile(
              dense: true,
              value: v,
              groupValue: group.getValue(),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${v ? S.current.chaldea_server_cn : S.current.chaldea_server_global}: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextSpan(text: Uri.parse(url).origin),
                  ],
                ),
              ),
              secondary: _getStatus(url),
              onChanged: (v) {
                setState(() {
                  if (v != null) group.onChanged(v);
                });
              },
            );
          }).toList(),
    );
  }

  Widget _getStatus(String url) {
    final resp = testResults[url];
    if (resp == null) return const Text('-');
    if (resp is Completer) {
      return const CupertinoActivityIndicator(radius: 9);
    }
    if (resp is Response) {
      final statusCode = resp.statusCode;
      return _textWithIndicator(statusCode.toString(), statusCode != null && statusCode >= 200 && statusCode < 300);
    } else if (resp is DioException) {
      return _textWithIndicator(resp.response?.statusCode?.toString() ?? 'Error', false, resp);
    } else {
      return _textWithIndicator(S.current.unknown, false, resp);
    }
  }

  Widget _textWithIndicator(String text, bool success, [dynamic error]) {
    Widget child = Text.rich(
      TextSpan(
        text: text,
        children: [
          TextSpan(text: ' ●', style: TextStyle(color: success ? Colors.green : Theme.of(context).colorScheme.error)),
        ],
      ),
    );
    child = Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), child: child);
    if (error == null) return child;
    return InkWell(
      onTap: () {
        String text;
        if (error is Response) {
          text = error.data.toString();
        } else if (error is DioException) {
          text = error.toString();
          if (error.response != null) {
            text += '\n${error.response!.data}';
          }
        } else {
          text = error.toString();
        }
        showDialog(
          context: context,
          builder: (context) {
            return SimpleCancelOkDialog(title: const Text('Error'), content: Text(text), hideCancel: true);
          },
        );
      },
      child: child,
    );
  }

  void _testNetwork() async {
    testResults.clear();
    setState(() {});
    for (final group in testGroups) {
      for (final url in [group.globalUrl, group.cnUrl]) {
        scheduleMicrotask(() async {
          final completer = testResults[url] = Completer();
          if (mounted) setState(() {});
          try {
            // await Future.delayed(const Duration(seconds: 2));
            final resp = await DioE().get(url);
            completer.complete(resp);
            testResults[url] = resp;
          } catch (e) {
            completer.complete(e);
            testResults[url] = e;
          }
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
