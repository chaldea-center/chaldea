import 'dart:convert';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/import_data/autologin/agent.dart';
import 'package:chaldea/app/modules/import_data/import_https_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'read_auth_page.dart';

class AutoLoginPage extends StatefulWidget {
  const AutoLoginPage({super.key});

  @override
  State<AutoLoginPage> createState() => _AutoLoginPageState();
}

class _AutoLoginPageState extends State<AutoLoginPage> {
  GameTops? gameTops;
  final allData = db.settings.autologins;
  AutoLoginData args = AutoLoginData();
  dynamic _error;

  @override
  void initState() {
    super.initState();
    if (allData.isEmpty) {
      allData.add(AutoLoginData());
    }
    args = allData.first;
    AtlasApi.gametops(expireAfter: null).then((value) {
      gameTops ??= value;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = gameTops?.of(args.region);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.import_auth_file),
        actions: [
          IconButton(
            onPressed: () {
              launch(ChaldeaUrl.doc('import_https/authfile_login'));
            },
            icon: const Icon(Icons.help_outline),
            tooltip: S.current.help,
          )
        ],
      ),
      body: ListView(
        children: [
          ...buildAccounts(),
          buildActions(),
          DividerWithTitle(height: 16, title: S.current.settings_tab_name),
          ListTile(
            dense: true,
            title: Text(S.current.game_server),
            trailing: FilterGroup<Region>(
              options: const [Region.jp, Region.na],
              values: FilterRadioData.nonnull(args.region),
              optionBuilder: (v) => Text(v.localName),
              combined: true,
              onFilterChanged: (v, _) {
                setState(() {
                  args.region = v.radioValue!;
                });
              },
            ),
          ),
          ListTile(
            title: Text(S.current.login_auth),
            dense: true,
            subtitle: Text(args.auth?.userId == null
                ? 'No Auth Loaded'
                : '${args.auth?.userId} (${args.auth?.userCreateServer ?? "unknown server"})'),
            trailing: IconButton(
              onPressed: onEditAuth,
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: S.current.edit,
            ),
            onTap: onEditAuth,
            selected: args.auth?.userId == null,
            selectedColor: Theme.of(context).colorScheme.error,
          ),
          if (args.auth?.userCreateServer != null &&
              !UserAuth.checkGameServer(args.region, args.auth!.userCreateServer!))
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${args.region.upper} ≠ ${args.auth?.userCreateServer}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const DividerWithTitle(title: 'Extra', indent: 16),
          ListTile(
            title: const Text('Game Info'),
            dense: true,
            selected: gameTops == null,
            selectedColor: Theme.of(context).colorScheme.error,
            subtitle: Text(top == null ? 'Not loaded' : 'appVer=${top.appVer},dataVer=${top.dataVer}'),
            trailing: IconButton(
              onPressed: () async {
                EasyLoading.show();
                final value = await AtlasApi.gametops(expireAfter: Duration.zero);
                EasyLoading.dismiss();
                if (value != null) {
                  gameTops = value;
                } else {
                  EasyLoading.showError(S.current.failed);
                }
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.refresh),
              tooltip: S.current.refresh,
            ),
          ),
          if (args.region == Region.na)
            ListTile(
              dense: true,
              title: const Text('Country'),
              trailing: DropdownButton<NACountry>(
                value: args.country,
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
                    if (v != null) args.country = v;
                  });
                },
              ),
            ),
          ListTile(
            dense: true,
            title: const Text('User Agent'),
            subtitle: Text(args.userAgent ?? UA.fallback),
            onLongPress: () {
              copyToClipboard(args.userAgent ?? UA.fallback, toast: true);
            },
            trailing: IconButton(
              onPressed: () {
                onEditArg(
                  'User Agent',
                  args.userAgent ?? UA.fallback,
                  (s) {
                    if (s.trim().isNotEmpty) {
                      args.userAgent = s.trim();
                    } else {
                      args.userAgent = null;
                    }
                  },
                  (s) => s.isEmpty || UA.validate(s),
                );
              },
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: S.current.edit,
            ),
          ),
          ListTile(
            dense: true,
            title: const Text('Device Info'),
            subtitle: Text(args.deviceInfo ?? UA.deviceinfo),
            onLongPress: () {
              copyToClipboard(args.deviceInfo ?? UA.deviceinfo, toast: true);
            },
            trailing: IconButton(
              onPressed: () {
                onEditArg(
                  'Device Info',
                  args.deviceInfo ?? UA.deviceinfo,
                  (s) {
                    if (s.trim().isNotEmpty) {
                      args.deviceInfo = s.trim();
                    } else {
                      args.deviceInfo = null;
                    }
                  },
                  null,
                );
              },
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: S.current.edit,
            ),
          ),
          Center(
            child: FilledButton.tonal(
              onPressed: updateDeviceInfo,
              child: Text(S.current.read_device_info),
            ),
          ),
          const Divider(height: 16, indent: 16, endIndent: 16),
          if (args.response != null)
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DefaultTextStyle.merge(child: buildResp(), style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
        ],
      ),
    );
  }

  void onEditAuth() {
    router.pushPage(ReadAuthPage(
      auth: args.auth,
      onChanged: (v) {
        if (v != null) args.auth = v;
        if (mounted) setState(() {});
      },
    ));
  }

  List<Widget> buildAccounts() {
    List<Widget> children = [];
    for (final user in allData) {
      Widget title = Text(
        '[${user.region}] ${user.auth?.friendCode ?? "Unknown"} ${user.auth?.name ?? ""}',
        style: const TextStyle(fontSize: 13),
      );
      Widget subtitle = Text('${user.auth?.userId}, last: ${user.lastLogin?.sec2date().toCustomString(year: false)}',
          style: const TextStyle(fontSize: 12));

      Widget trailing = TimerUpdate(builder: (context, time) {
        final userGame = user.result;
        List<InlineSpan> spans = [];
        if (userGame != null) {
          // final recoverAt = DateTime(2023, 10, 25, 2).timestamp;
          // final maxAp = 140;
          final recoverAt = userGame.actRecoverAt;
          final maxAp = userGame.actMax;
          final leftDuration = Duration(seconds: max(0, recoverAt - time.timestamp));
          final curAp =
              (maxAp - (recoverAt - time.timestamp) / 300).floor().clamp(0, maxAp) + userGame.carryOverActPoint;
          spans.add(TextSpan(text: 'AP $curAp/$maxAp'));
          spans.add(TextSpan(
            text: '\n${leftDuration.toString().split('.').first}',
            style: TextStyle(color: maxAp - curAp < 24 ? Theme.of(context).colorScheme.error : null),
          ));
          spans.add(const TextSpan(text: '\n'));
          spans.add(TextSpan(text: recoverAt.sec2date().toCustomString(year: false, second: false)));
        }
        return Text.rich(
          TextSpan(children: spans),
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.end,
        );
      });
      Widget tile = RadioListTile<AutoLoginData>(
        visualDensity: VisualDensity.compact,
        value: user,
        groupValue: args,
        title: title,
        subtitle: subtitle,
        secondary: trailing,
        onChanged: (v) {
          if (v != null) {
            args = v;
          }
          setState(() {});
        },
      );
      tile = ListTileTheme.merge(
        horizontalTitleGap: 8,
        minVerticalPadding: 0,
        child: tile,
      );
      children.add(tile);
    }
    children.add(const Divider(indent: 16, endIndent: 16));
    return children;
  }

  Widget buildActions() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            allData.add(AutoLoginData());
            args = allData.last;
            setState(() {});
          },
          icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
          tooltip: S.current.add,
        ),
        IconButton(
          onPressed: allData.length > 1
              ? () {
                  SimpleCancelOkDialog(
                    title: Text(S.current.delete),
                    onTapOk: () {
                      final prevIndex = allData.indexOf(args);
                      allData.remove(args);
                      args = allData[prevIndex.clamp(0, allData.length - 1)];
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                }
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: Theme.of(context).colorScheme.error,
          tooltip: S.current.remove,
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: doLogin,
          icon: const Icon(Icons.login),
          label: Text(S.current.login_login),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: args.response?.success == true ? () => _doImport(args.response!.text) : null,
          child: Text(S.current.import_data),
        )
      ],
    );
  }

  Future<void> updateDeviceInfo() async {
    if (!PlatformU.isAndroid) {
      EasyLoading.showInfo("Only Android device is supported");
      return;
    }
    try {
      EasyLoading.show();
      if (PlatformU.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        args.userAgent = "Dalvik/2.1.0 (Linux; U; Android ${info.version.release}; ${info.model} Build/${info.id})";
        args.deviceInfo =
            "${info.manufacturer} ${info.model} / Android OS ${info.version.release} / API-${info.version.sdkInt} (${info.id}/${info.version.incremental})";
      } else if (PlatformU.isIOS) {
        // final info = await DeviceInfoPlugin().iosInfo;
      }
      EasyLoading.showSuccess(S.current.updated);
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  void onEditArg(String title, String value, ValueChanged<String> onSubmit, bool Function(String v)? validate) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return InputCancelOkDialog(
          title: title,
          text: value,
          validate: validate,
          maxLines: 2,
          onSubmit: (s) {
            onSubmit(s);
            if (mounted) setState(() {});
          },
        );
      },
    );
  }

  Widget buildResp() {
    final buffer = StringBuffer();

    if (_error != null) {
      buffer.writeln('Error:\n\n$_error');
    } else {
      final src = args.response?.src;
      if (src == null) return const Text('No response');
      if (src.statusCode != 200) {
        buffer.writeln('status: ${src.statusCode}');
        buffer.writeln('statusText: ${src.statusMessage}');
      }
      final response = args.response;
      // buffer.writeln('data type: ${data.runtimeType}');
      buffer.writeln('server time: ${response?.serverTime ?? "unknown"}');
      buffer.writeln();
      final userGame = response?.userGame;
      buffer.writeln('server: ${response?.src.requestOptions.uri.host}');
      buffer.writeln('userId: ${userGame?.userId}');
      buffer.writeln('friendCode: ${userGame?.friendCode}');
      buffer.writeln('player name: ${userGame?.name}');
      buffer.writeln();

      dynamic data = response?.json?['response'];
      if (data != null) data = jsonEncode(data);
      buffer.writeln((data ?? src.data).toString().substring2(0, 2000));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Response",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(buffer.toString())
      ],
    );
  }

  void _doImport(String responseText) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.current.account_title),
          children: List.generate(db.userData.users.length, (index) {
            final user = db.userData.users[index];
            return SimpleDialogOption(
              child: Text('[${user.region.localName}] ${user.name}'),
              onPressed: () {
                db.userData.curUserKey = index;
                db.itemCenter.init();
                router.pushPage(ImportHttpPage(toploginText: responseText));
              },
            );
          }),
        );
      },
    );
  }

  Future doLogin() async {
    final args = this.args;
    _error = null;
    gameTops ??= await AtlasApi.gametops();
    final top = gameTops?.of(args.region);
    if (top == null) {
      EasyLoading.showError('Failed to load Game Info');
      return;
    }
    if (args.auth == null) {
      EasyLoading.showError('Auth info not loaded');
      return;
    }
    if (mounted) setState(() {});
    final agent = LoginAgent(auth: args.auth!, gameTop: top, args: args);
    try {
      EasyLoading.show(status: 'Login...');
      await agent.gamedata();
      args.response = FateServerResponse(await agent.topLogin());
      final userGame = args.response?.userGame;
      final serverTime = args.response?.serverTime;
      if (userGame != null) {
        args.result = userGame;
        args.lastLogin = serverTime?.timestamp ?? DateTime.now().timestamp;
      }
      if (args.response?.success == true) {
        await Future.delayed(const Duration(seconds: 1));
        EasyLoading.show(status: 'Login to home...');
        await agent.topHome();
        EasyLoading.showSuccess(S.current.success);
      } else {
        EasyLoading.showError('Login failed');
      }
    } catch (e, s) {
      logger.e('toplogin failed', e, s);
      _error = escapeDioException(e);
      EasyLoading.showError('Login failed\n$_error');
    } finally {
      if (mounted) setState(() {});
    }
  }
}
