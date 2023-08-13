import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/remote_config.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'chaldea_server_page.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  State<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends State<NetworkSettingsPage> {
  ConnectivityResult? _connectivity;
  late StreamSubscription<ConnectivityResult> _subscription;
  Map<String, dynamic> testResults = {};

  final testUrls = {
    'Chaldea Data': [
      '${HostsX.data.global}/version.json',
      '${HostsX.data.cn}/version.json',
    ],
    'Chaldea Server(Account)': [
      '${HostsX.worker.global}/network/ping',
      '${HostsX.worker.cn}/network/ping',
    ],
    'Chaldea Server(Recognizer)': [
      '${HostsX.api.global}/network/ping',
      '${HostsX.api.cn}/network/ping',
    ],
    'Atlas Api': [
      '${HostsX.atlasApi.global}/info',
      '${HostsX.atlasApi.cn}/info',
    ],
    'Atlas Assets': [
      '${HostsX.atlasAsset.global}/JP/Script/Common/QuestStart.txt',
      '${HostsX.atlasAsset.cn}/JP/Script/Common/QuestStart.txt',
    ],
  };

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.asBroadcastStream().listen((result) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _connectivity = network.connectivity;
    final serverHint = SFooter('1 - ${S.current.chaldea_server}: ${S.current.chaldea_server_global}\n'
        '2 - ${S.current.chaldea_server}: ${S.current.chaldea_server_cn}');
    return Scaffold(
      appBar: AppBar(title: Text(S.current.network_settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // const SizedBox(height: 16),
          TileGroup(
            footer: S.current.network_force_online_hint,
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.dns),
                title: Text(S.current.chaldea_server),
                horizontalTitleGap: 0,
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    db.onSettings((context, snapshot) =>
                        Text(db.settings.proxyServer ? S.current.chaldea_server_cn : S.current.chaldea_server_global)),
                    Icon(DirectionalIcons.keyboard_arrow_forward(context))
                  ],
                ),
                onTap: () {
                  router.pushPage(const ChaldeaServerPage());
                },
              ),
              ListTile(
                dense: true,
                title: Text(S.current.network_cur_connection),
                trailing: _textWithIndicator(
                    _connectivity?.name ?? '?', _connectivity != null && _connectivity != ConnectivityResult.none),
              ),
              SwitchListTile.adaptive(
                value: db.settings.forceOnline,
                title: Text(S.current.network_force_online),
                dense: true,
                onChanged: (v) {
                  setState(() {
                    db.settings.forceOnline = v;
                  });
                },
              ),
            ],
          ),
          const Divider(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: _testNetwork,
              child: Text(S.current.test),
            ),
          ),
          serverHint,
          for (final (key, urls) in testUrls.items) _buildGroup(key, urls),
          SafeArea(child: serverHint),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<String> urls) {
    return TileGroup(
      header: title,
      children: [
        for (final (index, url) in urls.enumerate)
          ListTile(
            dense: true,
            title: Text('${index + 1}  ${Uri.parse(url).origin}'),
            trailing: _getStatus(url),
          )
      ],
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
      return _textWithIndicator('Unknown', false, resp);
    }
  }

  Widget _textWithIndicator(String text, bool success, [dynamic error]) {
    Widget child = Text.rich(TextSpan(
      text: text,
      children: [
        TextSpan(
          text: ' ●',
          style: TextStyle(
            color: success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        )
      ],
    ));
    child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: child,
    );
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
            return SimpleCancelOkDialog(
              title: const Text('Error'),
              content: Text(text),
              hideCancel: true,
            );
          },
        );
      },
      child: child,
    );
  }

  void _testNetwork() async {
    testResults.clear();
    setState(() {});
    for (final group in testUrls.values) {
      for (final url in group) {
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
