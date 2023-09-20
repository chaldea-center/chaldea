import 'dart:convert';

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
  ServerResponse? response;
  dynamic _error;

  late final _userAgentCtrl = TextEditingController();
  late final _deviceInfoCtrl = TextEditingController();

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
  void dispose() {
    super.dispose();
    _userAgentCtrl.dispose();
    _deviceInfoCtrl.dispose();
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
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  value: allData.indexOf(args),
                  items: List.generate(allData.length, (index) {
                    final user = allData[index];
                    String text = '[${user.region.upper}] ${user.auth?.userId}';
                    if (user.auth?.friendCode != null) {
                      text += '\n (${user.auth?.friendCode} ${user.auth?.name})';
                    }
                    return DropdownMenuItem(
                      value: index,
                      child: Text(text, textScaleFactor: 0.9),
                    );
                  }),
                  onChanged: (v) {
                    if (v != null) {
                      args = db.settings.autologins[v];
                    }
                    setState(() {});
                  },
                  underline: const SizedBox(),
                  isExpanded: true,
                ),
              ),
              IconButton(
                onPressed: () {
                  allData.add(AutoLoginData());
                  args = allData.last;
                  setState(() {});
                },
                icon: const Icon(Icons.add_circle_outline),
                tooltip: S.current.add,
              ),
              IconButton(
                onPressed: allData.length > 1
                    ? () {
                        SimpleCancelOkDialog(
                          title: Text(S.current.delete),
                          onTapOk: () {
                            allData.remove(args);
                            args = allData.first;
                            if (mounted) setState(() {});
                          },
                        ).showDialog(context);
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.error,
                tooltip: S.current.add,
              ),
            ],
          ),
          const Divider(height: 16),
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
          ListTile(
            title: Text(S.current.login_auth),
            dense: true,
            subtitle: Text(args.auth?.userId == null
                ? 'No Auth Loaded'
                : '${args.auth?.userId} (${args.auth?.userCreateServer ?? "unknown server"})'),
            trailing: IconButton(
              onPressed: () {
                router.pushPage(ReadAuthPage(
                    auth: args.auth,
                    onChanged: (v) {
                      if (v != null) args.auth = v;
                      if (mounted) setState(() {});
                    }));
              },
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: S.current.edit,
            ),
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
                      child: Text(c.displayName, textScaleFactor: 0.8),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: doLogin,
              icon: const Icon(Icons.login),
              label: Text(S.current.login_login),
            ),
          ),
          const Divider(height: 16),
          if (response != null)
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
      final resp = response?.src;
      if (resp == null) return const Text('No response');
      if (resp.statusCode != 200) {
        buffer.writeln('status: ${resp.statusCode}');
        buffer.writeln('statusText: ${resp.statusMessage}');
      }
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
      buffer.writeln((data ?? resp.data).toString().substring2(0, 2000));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: response?.success == true ? () => _doImport(response!.text) : null,
          child: Text(S.current.import_data),
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
      response = ServerResponse(await agent.topLogin());
      if (response?.success == true) {
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
