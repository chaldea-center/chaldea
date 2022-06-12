import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/widgets/widgets.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({Key? key}) : super(key: key);

  @override
  State<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends State<NetworkSettingsPage> {
  ConnectivityResult? _connectivity;
  late StreamSubscription<ConnectivityResult> _subscription;
  Map<String, dynamic> testResults = {};

  final testUrls = {
    'Chaldea Data': [
      '${Hosts.kDataHostGlobal}/version.json',
      '${Hosts.kDataHostCN}/version.json',
    ],
    'Chaldea Server(Account)': [
      '${Hosts.kWorkerHostGlobal}/network/ping',
      '${Hosts.kWorkerHostCN}/network/ping',
    ],
    'Chaldea Server(Recognizer)': [
      '${Hosts.kApiHostGlobal}/network/ping',
      '${Hosts.kApiHostCN}/network/ping',
    ],
    'Atlas Api': [
      '${Hosts.kAtlasApiHostGlobal}/info',
      '${Hosts.kAtlasApiHostCN}/info',
    ],
    'Atlas Assets': [
      '${Hosts.kAtlasAssetHostGlobal}/JP/Script/Common/QuestStart.txt',
      '${Hosts.kAtlasAssetHostCN}/JP/Script/Common/QuestStart.txt',
    ],
  };

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _connectivity = network.connectivity;
    return Scaffold(
      appBar: AppBar(title: Text(S.current.network_settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _testNetwork,
              child: const Text('Test'),
            ),
          ),
          const SizedBox(height: 16),
          TileGroup(
            children: [
              ListTile(
                dense: true,
                title: Text(S.current.network_cur_connection),
                trailing: _textWithIndicator(
                    _connectivity?.name ?? '?',
                    _connectivity != null &&
                        _connectivity != ConnectivityResult.none),
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
          for (final entry in testUrls.entries)
            _buildGroup(entry.key, entry.value),
          SafeArea(
            child: SFooter(
                '1 - ${S.current.chaldea_server}: ${S.current.chaldea_server_global}\n'
                '2 - ${S.current.chaldea_server}: ${S.current.chaldea_server_cn}'),
          )
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<String> urls) {
    return TileGroup(
      header: title,
      children: [
        for (final url in urls)
          ListTile(
            dense: true,
            title: Text(Uri.parse(url).origin),
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
      return _textWithIndicator(statusCode.toString(),
          statusCode != null && statusCode >= 200 && statusCode < 300);
    } else if (resp is DioError) {
      return _textWithIndicator(
          resp.response?.statusCode?.toString() ?? 'Error', false, resp);
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
            color: success ? Colors.green : Theme.of(context).errorColor,
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
        } else if (error is DioError) {
          text = error.message;
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
            await Future.delayed(const Duration(seconds: 2));
            final resp = await Dio().get(url);
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
