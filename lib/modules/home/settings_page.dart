import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';
import 'package:chaldea/modules/_test_page.dart';
import 'package:chaldea/modules/home/subpage/login_page.dart';
import 'package:chaldea/modules/home/subpage/user_data_page.dart';
import 'package:flutter/foundation.dart';
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
  bool get alwaysOnTop => db.prefs.instance.getBool('alwaysOnTop') ?? false;

  set alwaysOnTop(bool v) => db.prefs.instance.setBool('alwaysOnTop', v);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings_tab_name)),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: 'User',
            children: [
              db.streamBuilder((context) => userTile),
            ],
          ),
          TileGroup(
            header: S.of(context).settings_data,
            children: <Widget>[
              db.streamBuilder(
                (context) => ListTile(
                  title: Text(S.of(context).cur_account),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        db.curUser.name,
                        style: TextStyle(color: Colors.black87),
                      ),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => AccountPage(),
                      popDetail: true,
                    );
                  },
                ),
              ),
              db.streamBuilder(
                (context) => ListTile(
                  title: Text(S.of(context).userdata),
                  subtitle: Text(S.current.backup_data_alert),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => UserDataPage(),
                      popDetail: true,
                    );
                  },
                ),
              ),
              db.streamBuilder(
                (context) => ListTile(
                  title: Text(S.of(context).gamedata),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(db.gameData.version),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => GameDataPage(),
                      detail: true,
                      popDetail: true,
                    );
                  },
                ),
              ),
            ],
          ),
          TileGroup(
            header: S.current.event_progress,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: progressDropdown,
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
                    return DropdownMenuItem(
                        value: lang, child: Text(lang.name));
                  }).toList(),
                  onChanged: (lang) {
                    if (lang == null) return;
                    db.userData.language = lang.code;
                    db.notifyAppUpdate();
                  },
                ),
              ),
              if (AppInfo.isMobile && SplitRoute.isSplit(context))
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
                  title: Text('Always On Top'),
                  onChanged: (v) async {
                    alwaysOnTop = v;
                    MethodChannelChaldea.setAlwaysOnTop(v);
                    setState(() {});
                  },
                ),
              // if (Platform.isAndroid || Platform.isIOS)
              //   SwitchListTile.adaptive(
              //     title: Text(S.of(context).settings_use_mobile_network),
              //     value: db.userData.useMobileNetwork ?? true,
              //     onChanged: (v) async {
              //       db.userData.useMobileNetwork = v;
              //       db.saveUserData();
              //       setState(() {});
              //     },
              //   ),
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
              ListTile(
                title: Text(S.of(context).settings_tutorial),
                onTap: () {
                  EasyLoading.showToast('咕咕咕咕咕咕');
                },
              ),
              if (Platform.isIOS)
                ListTile(
                  title: Text(S.of(context).join_beta),
                  onTap: () =>
                      launch('https://testflight.apple.com/join/HSyZttrr'),
                ),
              if (Platform.isIOS || Platform.isMacOS)
                ListTile(
                  title: Text(S.of(context).about_appstore_rating),
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
      ),
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
      db.curUser.msProgress = fixValidRange(db.curUser.msProgress, -2, -1);
    }

    final items = <DropdownMenuItem<int>>[
      DropdownMenuItem(
        value: -1,
        child: Text(S.current.progress_jp),
      ),
      DropdownMenuItem(
        value: -2,
        child: Text(S.current.progress_cn),
      ),
    ];
    items.addAll(sortedDates.map((date) => DropdownMenuItem(
          value: date.millisecondsSinceEpoch,
          child: Text(events[date]!.localizedName),
        )));
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
          detail: true,
        );
      },
    );
  }
}
