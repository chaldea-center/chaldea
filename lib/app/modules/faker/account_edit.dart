import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';
import '../import_data/autologin/read_auth_page.dart';

class FakerAccountEditPage extends StatefulWidget {
  final AutoLoginData user;
  final AutoLoginData Function(Map<String, dynamic> json) onImportJson;
  const FakerAccountEditPage({super.key, required this.user, required this.onImportJson});

  @override
  State<FakerAccountEditPage> createState() => _FakerAccountEditPageState();
}

class _FakerAccountEditPageState extends State<FakerAccountEditPage> {
  late AutoLoginData user = widget.user;
  final _textEditController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Scaffold(
      appBar: AppBar(title: Text('[${user.serverName}] ${user.userGame?.name ?? ""} ${user.userGame?.friendCode}')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (user is AutoLoginDataCN) ...buildCNRows(user),
          if (user is AutoLoginDataJP) ...buildJPRows(user),
          DividerWithTitle(title: '${S.current.general_export}/${S.current.general_import}', height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () {
                  String output;
                  try {
                    output = JsonEncoder.withIndent('  ').convert(user);
                    copyToClipboard(output, toast: true);
                  } catch (e) {
                    output = e.toString();
                    EasyLoading.showError(output);
                  }
                  setState(() {
                    _textEditController.text = output;
                  });
                },
                child: Text(S.current.general_export),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  try {
                    final prevUser = this.user;
                    final data = Map<String, dynamic>.from(jsonDecode(_textEditController.text));
                    final newUser = widget.onImportJson(data);
                    if (newUser.runtimeType != prevUser.runtimeType) {
                      EasyLoading.showError('RuntimeType changed: ${prevUser.runtimeType}->${newUser.runtimeType}');
                      return;
                    }
                    this.user = newUser;
                    EasyLoading.showSuccess('Re-enter this page to refresh');
                  } catch (e) {
                    EasyLoading.showError(e.toString());
                  } finally {
                    if (mounted) setState(() {});
                  }
                },
                child: Text(S.current.general_import),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: TextField(
              controller: _textEditController,
              decoration: InputDecoration(
                labelText: 'config',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: 10,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildJPRows(AutoLoginDataJP user) {
    return [
      ListTile(
        dense: true,
        title: Text(S.current.game_server),
        trailing: FilterGroup<Region>(
          options: const [Region.jp, Region.na],
          values: FilterRadioData.nonnull(user.region),
          optionBuilder: (v) => Text(v.localName),
          combined: true,
          onFilterChanged: (v, _) {
            setState(() {
              user.region = v.radioValue!;
            });
          },
        ),
      ),
      ListTile(
        title: Text(S.current.login_auth),
        dense: true,
        subtitle: Text(
          user.auth?.userId == null
              ? 'No Auth Loaded'
              : '${user.auth?.userId} (${user.auth?.userCreateServer ?? "unknown server"})',
        ),
        trailing: const Icon(Icons.edit_note_rounded),
        onTap: () {
          router.pushPage(
            ReadAuthPage(
              auth: user.auth,
              onChanged: (v) {
                if (v != null) user.auth = v;
                if (mounted) setState(() {});
              },
            ),
          );
        },
        selected: user.auth?.userId == null,
        selectedColor: Theme.of(context).colorScheme.error,
      ),
      if (user.auth?.userCreateServer != null &&
          !AuthSaveData.checkGameServer(user.region, user.auth!.userCreateServer!))
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${user.region.upper} ≠ ${user.auth?.userCreateServer}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      if (user.region == Region.na)
        ListTile(
          dense: true,
          title: const Text('Country'),
          trailing: DropdownButton<NACountry>(
            value: user.country,
            hint: const Text('Country'),
            items: [
              for (final c in NACountry.values)
                DropdownMenuItem(value: c, child: Text(c.displayName, textScaler: const TextScaler.linear(0.8))),
            ],
            onChanged: (v) {
              setState(() {
                if (v != null) user.country = v;
              });
            },
          ),
        ),
      const Divider(),
      buildRow('Device Info', user.deviceInfo, (s) => user.deviceInfo = s.trim().isEmpty ? null : s.trim()),
      buildRow('User-Agent', user.userAgent, (s) => user.userAgent = s.trim()),
      Center(
        child: FilledButton.tonal(onPressed: () => updateDeviceInfoJP(user), child: Text(S.current.read_device_info)),
      ),
    ];
  }

  List<Widget> buildCNRows(AutoLoginDataCN user) {
    return [
      ListTile(
        dense: true,
        title: const Text('区服'),
        subtitle:
            user.gameServer == BiliGameServer.uo
                ? Text('不支持渠道服!', style: TextStyle(color: Theme.of(context).colorScheme.error))
                : null,
        trailing: DropdownButton<BiliGameServer>(
          value: user.gameServer,
          items: [
            for (final server in BiliGameServer.values)
              DropdownMenuItem(value: server, child: Text(server.shownName, style: const TextStyle(fontSize: 14))),
          ],
          onChanged: (v) {
            setState(() {
              if (v != null) user.gameServer = v;
            });
          },
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('设备类型'),
        trailing: DropdownButton<bool>(
          value: user.isAndroidDevice,
          items: [
            for (final isAndroid in [true, false])
              DropdownMenuItem(
                value: isAndroid,
                child: Text(isAndroid ? 'Android' : 'iOS', style: const TextStyle(fontSize: 14)),
              ),
          ],
          onChanged: (v) {
            setState(() {
              if (v != null) user.isAndroidDevice = v;
            });
          },
        ),
      ),
      buildRow('B站UID', user.uid.toString(), (s) {
        final v = int.parse(s);
        if (v > 0) user.uid = v;
      }),
      buildRow('B站用户名', user.username, (s) => user.username = s),
      buildRow('御主名/游戏内用户名', user.nickname, (s) => user.nickname = s),
      buildRow('access_token', user.accessToken, (s) => user.accessToken = s),
      buildRow('deviceId', user.deviceId, (s) => user.deviceId = s),
      const Divider(),
      // buildRow('rkchannel', user.rkchannel.toString(), (s) => user.rkchannel = int.parse(s)),
      // buildRow('cPlat', user.cPlat.toString(), (s) => user.cPlat = int.parse(s)),
      // buildRow('uPlat', user.uPlat.toString(), (s) => user.uPlat = int.parse(s)),
      buildRow('os', user.os, (s) => user.os = s.trim()),
      buildRow('ptype', user.ptype, (s) => user.ptype = s.trim()),
      buildRow('User-Agent', user.userAgent, (s) => user.userAgent = s.trim()),
      Center(
        child: FilledButton.tonal(onPressed: () => updateDeviceInfoCN(user), child: Text(S.current.read_device_info)),
      ),
    ];
  }

  Widget buildRow(String title, String? value, void Function(String s) onSubmit) {
    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: Text(
        value == null || value.isEmpty ? 'not set' : value,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: () {
        InputCancelOkDialog(
          title: title,
          text: value,
          onSubmit: (s) {
            try {
              setState(() {
                onSubmit(s);
              });
            } catch (e) {
              EasyLoading.showError(e.toString());
            }
          },
        ).showDialog(context);
      },
      onLongPress: () {
        if (value != null && value.isNotEmpty) {
          copyToClipboard(value, toast: true);
        }
      },
    );
  }

  Future<void> updateDeviceInfoJP(AutoLoginDataJP user) async {
    try {
      EasyLoading.show();
      if (PlatformU.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        user.userAgent =
            (await MethodChannelChaldea.getUserAgent()) ??
            "Dalvik/2.1.0 (Linux; U; Android ${info.version.release}; ${info.model} Build/${info.id})";
        final deviceModel = "${info.manufacturer} ${info.model}",
            operatingSystem =
                "Android OS ${info.version.release} / API-${info.version.sdkInt} (${info.id}/${info.version.incremental})";
        user.deviceInfo = "$deviceModel / $operatingSystem";
      } else if (PlatformU.isIOS) {
        final gameTop = (await AtlasApi.gametops())?.of(user.region);
        final info = await DeviceInfoPlugin().iosInfo;
        final cfNetworkVersion = await MethodChannelChaldea.getCFNetworkVersion() ?? "1474";
        user.userAgent = "FateGO/${gameTop?.appVer ?? 0} CFNetwork/$cfNetworkVersion Darwin/${info.utsname.release}";
        final deviceModel = info.utsname.machine,
            operatingSystem = info.model.toLowerCase().contains('ipad') ? "iPad OS" : "iPhone OS";
        user.deviceInfo = "$deviceModel / $operatingSystem";
      } else {
        EasyLoading.showInfo("Only Android/iOS device supported");
        return;
      }
      EasyLoading.showSuccess(S.current.updated);
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> updateDeviceInfoCN(AutoLoginDataCN user) async {
    try {
      EasyLoading.show();
      if (user.isAndroidDevice ? PlatformU.isIOS : PlatformU.isAndroid) {
        EasyLoading.showError('设置的“设备类型”与本机不符');
        return;
      }
      if (PlatformU.isAndroid) {
        final gameTop = (await AtlasApi.gametops())?.of(user.region);
        final info = await DeviceInfoPlugin().androidInfo;
        user.userAgent = "UnityPlayer/${gameTop?.unityVer ?? '2022.3.28f1'} (UnityWebRequest/1.0, libcurl/8.4.0-DEV)";
        user.os =
            "Android OS ${info.version.release} / API-${info.version.sdkInt} (${info.id}/${info.version.incremental})";
        user.ptype = "${info.manufacturer} ${info.model}";
      } else if (PlatformU.isIOS) {
        final info = await DeviceInfoPlugin().iosInfo;
        final cfNetworkVersion = await MethodChannelChaldea.getCFNetworkVersion() ?? "1474";
        user.userAgent = "fatego/20 CFNetwork/$cfNetworkVersion Darwin/${info.utsname.release}";
        user.os = "${info.systemName} ${info.systemVersion}";
        user.ptype = info.utsname.machine;
        // rkchannel/cPlat/uPlat
      } else {
        EasyLoading.showInfo("Only Android/iOS device supported");
        return;
      }
      EasyLoading.showSuccess(S.current.updated);
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      if (mounted) setState(() {});
    }
  }
}
