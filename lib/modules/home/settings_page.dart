import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:chaldea/modules/home/subpage/dataset_manage_page.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'subpage/about_page.dart';
import 'subpage/account_page.dart';
import 'subpage/feedback_page.dart';
import 'subpage/update_source_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            header: S.of(context).settings_data,
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).settings_tutorial),
                onTap: () {
                  EasyLoading.showToast('咕咕咕咕咕咕');
                },
              ),
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
                  title: Text(S.of(context).settings_data_management),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(db.gameData.version),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => DatasetManagePage(),
                      popDetail: true,
                    );
                  },
                ),
              ),
              db.streamBuilder(
                (context) => ListTile(
                  title: Text(S.of(context).download_source),
                  subtitle: Text(S.of(context).download_source_hint),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(GitSource.values[db.userData.updateSource]
                          .toTitleString()),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => UpdateSourcePage(),
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
                    db.saveUserData();
                    db.notifyAppUpdate();
                  },
                ),
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
                onTap: () => SplitRoute.push(
                  context: context,
                  builder: (context, _) => AboutPage(),
                  popDetail: true,
                ),
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
                  title: Text('Google Play Store'),
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
          if (kDebugMode_)
            TileGroup(
              header: 'Test(debug mode: ${kDebugMode ? 'on' : 'off'})',
              children: <Widget>[
                ListTile(
                  title: Text('Generate Error'),
                  onTap: () {
                    throw FormatException('generated error');
                  },
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
}
