import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';
import 'package:chaldea/modules/_test_page.dart';
import 'package:chaldea/modules/home/subpage/carousel_setting_page.dart';
import 'package:chaldea/modules/home/subpage/game_server_page.dart';
import 'package:chaldea/modules/home/subpage/login_page.dart';
import 'package:chaldea/modules/home/subpage/user_data_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'subpage/about_page.dart';
import 'subpage/account_page.dart';
import 'subpage/feedback_page.dart';
import 'subpage/game_data_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool get alwaysOnTop => db.cfg.get('alwaysOnTop') ?? false;

  set alwaysOnTop(bool v) => db.cfg.put('alwaysOnTop', v);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings_tab_name)),
      body: db.streamBuilder((context) => body),
    );
  }

  Widget _wrapArrowTrailing(Widget trailing) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[trailing, Icon(Icons.keyboard_arrow_right)],
    );
  }

  Widget get body {
    return ListView(
      children: <Widget>[
        TileGroup(
          header: 'Chaldea User',
          children: [userTile],
        ),
        TileGroup(
          header: S.current.cur_account,
          children: [
            ListTile(
              title: Text(S.of(context).cur_account),
              trailing: _wrapArrowTrailing(Text(db.curUser.name)),
              onTap: () {
                SplitRoute.push(
                  context: context,
                  builder: (context, _) => AccountPage(),
                  popDetail: true,
                );
              },
            ),
            ListTile(
              title: Text(S.current.server),
              trailing: _wrapArrowTrailing(Text(db.curUser.server.localized)),
              onTap: () {
                SplitRoute.push(
                  context: context,
                  builder: (ctx, _) => GameServerPage(),
                  popDetail: true,
                );
              },
            ),
          ],
        ),
        TileGroup(
          header: S.current.event_progress,
          footer:
              '${S.current.limited_event}/${S.current.main_record}/${S.current.summon}',
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: progressDropdown,
            ),
          ],
        ),
        TileGroup(
          header: S.of(context).settings_data,
          children: <Widget>[
            ListTile(
              title: Text(S.of(context).userdata),
              // subtitle: Text(S.current.backup_data_alert),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                SplitRoute.push(
                  context: context,
                  builder: (context, _) => UserDataPage(),
                  popDetail: true,
                );
              },
            ),
            ListTile(
              title: Text(S.of(context).gamedata),
              trailing: _wrapArrowTrailing(Text(db.gameData.version)),
              onTap: () {
                SplitRoute.push(
                  context: context,
                  builder: (context, _) => GameDataPage(),
                  detail: true,
                  popDetail: true,
                );
              },
            ),
          ],
        ),
        TileGroup(
          header: S.of(context).settings_general,
          children: <Widget>[
            ListTile(
              title: Text(S.of(context).settings_language),
              subtitle: Language.isEN ? null : Text('Language'),
              trailing: DropdownButton<Language>(
                underline: Divider(thickness: 0, color: Colors.transparent),
                value: Language.getLanguage(
                    db.userData.language ?? Language.currentLocaleCode),
                items: Language.supportLanguages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang.name));
                }).toList(),
                onChanged: (lang) {
                  if (lang == null) return;
                  db.userData.language = lang.code;
                  db.notifyAppUpdate();
                },
              ),
            ),
            ListTile(
              title: Text(LocalizedText.of(
                  chs: '深色模式', jpn: 'ダークモード', eng: 'Dark Mode')),
              trailing: DropdownButton<ThemeMode>(
                value: db.userData.themeMode ?? ThemeMode.system,
                underline: Container(),
                items: [
                  DropdownMenuItem(
                      child: Text(LocalizedText.of(
                          chs: '系统', jpn: 'System', eng: 'System')),
                      value: ThemeMode.system),
                  DropdownMenuItem(
                      child: Text(LocalizedText.of(
                          chs: '浅色', jpn: 'Light', eng: 'Light')),
                      value: ThemeMode.light),
                  DropdownMenuItem(
                      child: Text(LocalizedText.of(
                          chs: '深色', jpn: 'Dark', eng: 'Dark')),
                      value: ThemeMode.dark),
                ],
                onChanged: (v) {
                  if (v != null) {
                    db.userData.themeMode = v;
                    db.notifyAppUpdate();
                  }
                },
              ),
            ),
            // only show on mobile phone, not desktop and tablet
            // on Android, cannot detect phone or mobile
            if (AppInfo.isMobile && !AppInfo.isIPad)
              SwitchListTile.adaptive(
                value: db.userData.autorotate,
                title: Text(S.current.setting_auto_rotate),
                onChanged: (v) {
                  db.userData.autorotate = v;
                  db.notifyAppUpdate();
                },
              ),
            if (Platform.isMacOS || Platform.isWindows)
              SwitchListTile.adaptive(
                value: alwaysOnTop,
                title: Text(LocalizedText.of(
                    chs: '置顶显示', jpn: 'スティッキー表示', eng: 'Always On Top')),
                onChanged: (v) async {
                  alwaysOnTop = v;
                  MethodChannelChaldea.setAlwaysOnTop(v);
                  setState(() {});
                },
              ),
            ListTile(
              title: Text(S.current.carousel_setting),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                SplitRoute.push(
                  context: context,
                  builder: (_, __) => CarouselSettingPage(),
                ).then((value) => db.notifyAppUpdate());
              },
            )
          ],
        ),
        TileGroup(
          header: S.of(context).about_app,
          children: <Widget>[
            ListTile(
              title: Text(MaterialLocalizations.of(context)
                  .aboutListTileTitle(AppInfo.appName)),
              trailing: db.runtimeData.upgradableVersion == null
                  ? null
                  : Text(
                      db.runtimeData.upgradableVersion!.version + ' ↑',
                      style: TextStyle(),
                    ),
              onTap: () => SplitRoute.push(
                context: context,
                builder: (context, _) => AboutPage(),
                popDetail: true,
              ),
            ),
            if (!kReleaseMode)
              ListTile(
                title: Text(S.of(context).settings_tutorial),
                onTap: () {
                  EasyLoading.showToast(
                      Language.isCN ? '咕咕咕咕咕咕' : "Not implemented");
                },
              ),
            ListTile(
              title: Text(S.of(context).about_feedback),
              onTap: () {
                SplitRoute.push(
                  context: context,
                  builder: (context, _) => FeedbackPage(),
                  detail: true,
                  popDetail: true,
                );
              },
            ),
            if (Platform.isIOS || Platform.isMacOS)
              ListTile(
                title: Text('Rate on App Store'),
                onTap: () {
                  launch(kAppStoreLink);
                },
              ),
            if (Platform.isAndroid)
              ListTile(
                title: Text('Rate on Google Play'),
                onTap: () {
                  launch(kGooglePlayLink);
                },
              ),
            ListTile(
              title: Text(S.current.share),
              onTap: () => _ShareAppDialog().showDialog(context),
            )
          ],
        ),
        TileGroup(
          header: 'Support Chaldea',
          children: [
            ListTile(
              title: Text('Starring on Github'),
              subtitle: Text(kProjectHomepage),
              onTap: () {
                launch(kProjectHomepage);
              },
            ),
            ListTile(
              title: Text(S.current.support_chaldea),
              onTap: () {
                launch(kProjectHomepage + '/wiki/Support');
              },
            ),
            ListTile(
              title: Text('Contribution/Collaboration'),
              subtitle: Text('e.g. Translation'),
              onTap: () {
                SimpleCancelOkDialog(
                  title: Text('Contribute to Chaldea'),
                  content: Text(
                      'Collaboration is welcomed, please contact us through email:\n'
                      '$kSupportTeamEmailAddress'),
                  scrollable: true,
                ).showDialog(context);
              },
            )
          ],
        ),
        if (kDebugMode)
          TileGroup(
            header: 'Test(debug mode: ${kDebugMode ? 'on' : 'off'})',
            children: <Widget>[
              ListTile(
                title: Text('Test Func'),
                onTap: testFunction,
              ),
              ListTile(
                title: Text('Master-Detail width'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: db.runtimeData.criticalWidth ?? 768,
                    items: <DropdownMenuItem<double>>[
                      DropdownMenuItem(value: 768, child: Text('768')),
                      DropdownMenuItem(value: 600, child: Text('600'))
                    ],
                    onChanged: (v) {
                      db.runtimeData.criticalWidth = v;
                      db.notifyAppUpdate();
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget get progressDropdown {
    Map<DateTime, EventBase> events = {};
    db.gameData.events.allEvents.forEach((key, event) {
      final DateTime? startTime = event.startTimeJp?.toDateTime();
      if (startTime != null && !events.containsValue(startTime)) {
        events[startTime] = event;
      }
    });
    List<DateTime> sortedDates = events.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    if (db.curUser.msProgress > 0) {
      db.curUser.msProgress = sortedDates
              .firstWhereOrNull((e) =>
                  e.millisecondsSinceEpoch > 0 &&
                  e.millisecondsSinceEpoch <= db.curUser.msProgress)
              ?.millisecondsSinceEpoch ??
          -1;
    } else {
      db.curUser.msProgress = fixValidRange(db.curUser.msProgress, -4, -1);
    }
    Widget _wrapText(String text) => Text(
          text,
          maxLines: 2,
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        );

    final items = <DropdownMenuItem<int>>[
      DropdownMenuItem(
          value: -1,
          child: _wrapText(S.current.sync_server(S.current.server_jp))),
      DropdownMenuItem(
          value: -2,
          child: _wrapText(S.current.sync_server(S.current.server_cn))),
      DropdownMenuItem(
          value: -3,
          child: _wrapText(S.current.sync_server(S.current.server_tw))),
      DropdownMenuItem(
          value: -4,
          child: _wrapText(S.current.sync_server(S.current.server_na))),
    ];
    for (var date in sortedDates) {
      items.add(DropdownMenuItem(
        value: date.millisecondsSinceEpoch,
        child: _wrapText(events[date]!.localizedName),
      ));
    }
    if (db.curUser.msProgress > 0) {
      db.curUser.msProgress = items
              .firstWhereOrNull(
                  (e) => e.value! > 0 && e.value! <= db.curUser.msProgress)
              ?.value ??
          -1;
    }
    return DropdownButton<int>(
      value: db.curUser.msProgress,
      isExpanded: true,
      items: items,
      itemHeight: null,
      underline: Container(),
      onChanged: (v) {
        setState(() {
          db.curUser.msProgress = v ?? db.curUser.msProgress;
        });
      },
    );
  }

  Widget get userTile {
    String? userName = db.prefs.userName.get();
    String? userPwd = db.prefs.userPwd.get();
    String trailing;
    if (userName == null || userPwd == null) {
      trailing = S.current.login_state_not_login;
    } else {
      trailing = userName;
    }
    return ListTile(
      title: Text(S.current.login_username),
      trailing: Text(trailing),
      onTap: () async {
        SplitRoute.push(
          context: context,
          builder: (context, _) => LoginPage(),
          popDetail: true,
        );
      },
    );
  }
}

class _ShareAppDialog extends StatefulWidget {
  const _ShareAppDialog({Key? key}) : super(key: key);

  @override
  __ShareAppDialogState createState() => __ShareAppDialogState();
}

class __ShareAppDialogState extends State<_ShareAppDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    String msg = LocalizedText.of(
      chs:
          "Chaldea——一款跨平台的Fate/GO素材规划客户端，支持游戏信息浏览、从者练度/活动/素材规划、周常规划、抽卡模拟器等功能。\n"
          "iOS&Mac App Store: $kAppStoreHttpLink\n"
          "Google Play: $kGooglePlayLink\n"
          "Windows/macOS/Android安装包:\n${kProjectHomepage + '/releases'}",
      jpn:
      "Chaldea - クロスプラットフォームのFate/GOアイテム計画アプリ。ゲーム情報の閲覧、サーヴァント/イベント/アイテム計画、マスターミッション計画、ガチャシミュレーターなどの機能をサポートします。\n"
          "iOS&Mac App Store: $kAppStoreHttpLink\n"
          "Google Play: $kGooglePlayLink\n"
          "Windows/macOS/Android:\n${kProjectHomepage + '/releases'}",
      eng:
      "Chaldea - A cross-platform utility for Fate/GO. Supporting game data review, servant/event/item planning, master mission planning, summon simulator and so on.\n"
          "iOS&Mac App Store: $kAppStoreHttpLink\n"
          "Google Play: $kGooglePlayLink\n"
          "Windows/macOS/Android installer:\n${kProjectHomepage + '/releases'}",
    );
    _controller = TextEditingController(text: msg);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.share),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 12.0),
      content: TextField(
        controller: _controller,
        maxLines: null,
        minLines: 5,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).highlightColor,
          focusColor: Theme.of(context).highlightColor,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dialogBackgroundColor)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dialogBackgroundColor)),
        ),
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _controller.text)).then((_) {
              EasyLoading.showSuccess('Copied');
            }).catchError((e, s) {
              logger.e('copy share msg failed', e, s);
              EasyLoading.showError('Copy failed');
            });
          },
          child: Text(MaterialLocalizations.of(context).copyButtonLabel),
        ),
        if (!Platform.isWindows)
          TextButton(
            onPressed: () {
              Share.share(_controller.text).catchError((e, s) {
                logger.e('Share text failed', e, s);
              });
            },
            child: Text(S.current.share),
          ),
      ],
    );
  }
}
