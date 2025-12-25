import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/cn/agent.dart' show FakerAgentCN;
import 'package:chaldea/models/faker/quiz/cat_mouse.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/common/filter_group.dart';
import '../../modules/import_data/autologin/read_auth_page.dart';
import '../runtime.dart';

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

  FakerRuntime? runtime;

  @override
  void dispose() {
    super.dispose();
    _textEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('[${user.serverName}] ${user.userGame?.displayName ?? ""} ${user.userGame?.friendCode}'),
        actions: [?runtime?.buildHistoryButton(context)],
      ),
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
                DropdownMenuItem(
                  value: c,
                  child: Text(c.displayName, textScaler: const TextScaler.linear(0.8)),
                ),
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
        subtitle: user.gameServer == BiliGameServer.uo
            ? Text('不支持渠道服!', style: TextStyle(color: Theme.of(context).colorScheme.error))
            : null,
        trailing: DropdownButton<BiliGameServer>(
          value: user.gameServer,
          items: [
            for (final server in BiliGameServer.values)
              DropdownMenuItem(
                value: server,
                child: Text(server.shownName, style: const TextStyle(fontSize: 14)),
              ),
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
      const Divider(),
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
      buildRow('system version', user.sysVer, (s) => user.sysVer = s.trim()),
      buildRow('ptype', user.ptype, (s) => user.ptype = s.trim()),
      buildRow('User-Agent', user.userAgent, (s) => user.userAgent = s.trim()),
      Center(
        child: FilledButton.tonal(onPressed: () => updateDeviceInfoCN(user), child: Text(S.current.read_device_info)),
      ),
      const Divider(),
      buildRow('账号', user.biliUserId, (s) => user.biliUserId = s),
      buildRow(
        '密码',
        CatMouseGame().encodeObjMsgpackBase64('') == user.biliPasswd ? null : '**' * 4,
        (s) => user.biliPasswd = CatMouseGame().encodeJsonMsgpackBase64(s),
      ),
      buildRow(
        'bdid',
        user.bdid.toString(),
        (s) {
          if (s.length != 64) {
            throw ArgumentError.value(s, 'bdid', 'Must be 64 length');
          }
          user.bdid = s;
        },
        maxLength: 64,
        trailing: IconButton(
          onPressed: () {
            String bdid = '${const Uuid().v4()}-${const Uuid().v4()}';
            if (bdid.length > 64) bdid = bdid.substring(0, 64);
            SimpleConfirmDialog(
              title: Text('Generated bdid'),
              content: Text('${user.bdid}\n↓\n$bdid'),
              onTapOk: () {
                user.bdid = bdid;
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          },
          icon: Icon(Icons.generating_tokens),
          tooltip: 'Generate',
        ),
      ),
      buildRow(
        'buvid',
        user.buvid.toString(),
        (s) {
          String? reason;
          if (s.length != 37) {
            reason = 'Must be uuid string';
          } else if (s.toUpperCase() != s) {
            reason = 'Must be upper case';
          } else if (!s.startsWith('XX') && !s.startsWith('XY') && !s.startsWith('XZ') && !s.startsWith('XW')) {
            reason = 'Invalid start two chars';
          } else if (s[2] != s[2 + 5] || s[3] != s[12 + 5] || s[4] != s[22 + 5]) {
            reason = 'Invalid salt';
          }
          if (reason != null) {
            throw ArgumentError.value(s, 'buvid', reason);
          }
          user.buvid = s;
        },
        maxLength: 37,
        trailing: IconButton(
          onPressed: () {
            String baseId = const Uuid().v4().toUpperCase();
            // XZ-imei, XY-wifiMacAddr, XX-androidId, XW-randomUUID.replace("-","")
            String strMd5 = md5.convert(utf8.encode(baseId)).toString();
            String salt = strMd5[2] + strMd5[12] + strMd5[22];
            String buvid = 'XX$salt$strMd5'.toUpperCase();
            SimpleConfirmDialog(
              title: Text('Generated buvid V2'),
              content: Text('${user.buvid}\n↓\n$buvid'),
              onTapOk: () {
                user.buvid = buvid;
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          },
          icon: Icon(Icons.generating_tokens),
          tooltip: 'Generate',
        ),
      ),
      Center(
        child: FilledButton.tonal(
          onPressed: () async {
            final _runtime = runtime ??= await FakerRuntime.init(user, null);
            await _runtime.runTask(() async {
              await (_runtime.agent as FakerAgentCN).biliSdkLogin();
            });
          },
          child: Text('Login'),
        ),
      ),
      const Divider(),
    ];
  }

  Widget buildRow(String title, String? value, void Function(String s) onSubmit, {Widget? trailing, int? maxLength}) {
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
          initValue: value,
          maxLength: maxLength,
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
      trailing: trailing,
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
        user.sysVer = info.version.release;
        user.os =
            "Android OS ${info.version.release} / API-${info.version.sdkInt} (${info.id}/${info.version.incremental})";
        user.ptype = "${info.manufacturer} ${info.model}";
      } else if (PlatformU.isIOS) {
        final info = await DeviceInfoPlugin().iosInfo;
        final cfNetworkVersion = await MethodChannelChaldea.getCFNetworkVersion() ?? "1474";
        user.userAgent = "fatego/20 CFNetwork/$cfNetworkVersion Darwin/${info.utsname.release}";
        user.sysVer = info.systemVersion;
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
