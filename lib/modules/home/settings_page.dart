import 'package:chaldea/_test_page.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/debug/debug_floating_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'subpage/about_page.dart';
import 'subpage/account_page.dart';
import 'subpage/display_setting_page.dart';
import 'subpage/feedback_page.dart';
import 'subpage/game_data_page.dart';
import 'subpage/game_server_page.dart';
import 'subpage/login_page.dart';
import 'subpage/share_app_dialog.dart';
import 'subpage/support_donation_page.dart';
import 'subpage/user_data_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
      children: <Widget>[trailing, const Icon(Icons.keyboard_arrow_right)],
    );
  }

  Widget get body {
    return ListView(
      controller: _scrollController,
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
                SplitRoute.push(context, AccountPage(), popDetail: true);
              },
            ),
            ListTile(
              title: Text(S.current.server),
              trailing: _wrapArrowTrailing(Text(db.curUser.server.localized)),
              onTap: () {
                SplitRoute.push(context, GameServerPage(), popDetail: true);
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                SplitRoute.push(context, UserDataPage(), popDetail: true);
              },
            ),
            ListTile(
              title: Text(S.of(context).gamedata),
              trailing: _wrapArrowTrailing(Text(db.gameData.version)),
              onTap: () {
                SplitRoute.push(context, GameDataPage(), popDetail: true);
              },
            ),
          ],
        ),
        TileGroup(
          header: S.of(context).settings_general,
          children: <Widget>[
            ListTile(
              title: Text(S.of(context).settings_language),
              subtitle: Language.isEN ? null : const Text('Language'),
              trailing: DropdownButton<Language>(
                underline:
                    const Divider(thickness: 0, color: Colors.transparent),
                value: Language.getLanguage(
                    db.appSetting.language ?? Language.currentLocaleCode),
                items: Language.supportLanguages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang.name));
                }).toList(),
                onChanged: (lang) {
                  if (lang == null) return;
                  db.appSetting.language = lang.code;
                  db.notifyAppUpdate();
                },
              ),
            ),
            ListTile(
              title: Text(LocalizedText.of(
                  chs: '深色模式', jpn: 'ダークモード', eng: 'Dark Mode')),
              trailing: DropdownButton<ThemeMode>(
                value: db.appSetting.themeMode ?? ThemeMode.system,
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
                    db.appSetting.themeMode = v;
                    db.notifyAppUpdate();
                  }
                },
              ),
            ),
            ListTile(
              title: Text(S.current.display_setting),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                SplitRoute.push(context, DisplaySettingPage());
              },
            ),
          ],
        ),
        TileGroup(
          header: S.of(context).about_app,
          children: <Widget>[
            ListTile(
              title: Text(MaterialLocalizations.of(context)
                  .aboutListTileTitle(AppInfo.appName)),
              trailing: db.runtimeData.upgradableVersion == null
                  ? const Icon(Icons.keyboard_arrow_right)
                  : Text(
                      db.runtimeData.upgradableVersion!.version + ' ↑',
                    ),
              onTap: () => SplitRoute.push(
                context,
                AboutPage(),
                popDetail: true,
              ),
            ),
            ListTile(
              title: Text(S.of(context).about_feedback),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                SplitRoute.push(context, FeedbackPage(), popDetail: true);
              },
            ),
            if (!kReleaseMode)
              ListTile(
                title: Text(S.of(context).settings_tutorial),
                trailing: const Icon(Icons.menu_book),
                onTap: () {
                  EasyLoading.showToast(
                      Language.isCN ? '咕咕咕咕咕咕' : "Not implemented");
                },
              ),
            if (!PlatformU.isApple || (db.cfg.launchTimes.get() ?? 0) > 5)
              ListTile(
                title: Text(S.current.support_chaldea),
                trailing: const Icon(Icons.favorite),
                onTap: () {
                  SplitRoute.push(context, SupportDonationPage());
                },
              ),
            if (PlatformU.isApple)
              ListTile(
                title: Text(LocalizedText.of(
                    chs: 'App Store评分',
                    jpn: 'App Storeでのレート ',
                    eng: 'Rate on App Store')),
                trailing: const Icon(Icons.star_half_rounded),
                onTap: () {
                  launch(kAppStoreLink);
                },
              ),
            if (PlatformU.isAndroid)
              ListTile(
                title: Text(LocalizedText.of(
                    chs: 'Google Play评分',
                    jpn: 'Google Playでのレート ',
                    eng: 'Rate on Google Play')),
                trailing: const Icon(Icons.star_half_rounded),
                onTap: () {
                  launch(kGooglePlayLink);
                },
              ),
            ListTile(
              title: Text(S.current.share),
              trailing: const Icon(Icons.ios_share),
              onTap: () => ShareAppDialog().showDialog(context),
            ),
            ListTile(
              title: const Text('Starring on Github'),
              subtitle: const Text(kProjectHomepage),
              onTap: () {
                launch(kProjectHomepage);
              },
            ),
            ListTile(
              title: const Text('Contribution/Collaboration'),
              subtitle: const Text('e.g. Translation'),
              onTap: () {
                const SimpleCancelOkDialog(
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
                title: const Text('Test Func'),
                onTap: () => testFunction(context),
              ),
              SwitchListTile.adaptive(
                value: db.runtimeData.showDebugFAB,
                title: const Text('Debug FAB'),
                onChanged: (v) {
                  setState(() {
                    db.runtimeData.showDebugFAB = v;
                  });
                  if (v) {
                    DebugFloatingMenuButton.createOverlay(context);
                  } else {
                    DebugFloatingMenuButton.removeOverlay();
                  }
                },
              ),
              ListTile(
                title: const Text('Master-Detail width'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: db.runtimeData.criticalWidth ?? 768,
                    items: const <DropdownMenuItem<double>>[
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
          style: const TextStyle(fontSize: 14),
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
        SplitRoute.push(context, LoginPage(), popDetail: true);
      },
    );
  }
}
