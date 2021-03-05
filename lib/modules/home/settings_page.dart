//@dart=2.9
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
  String user;

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
//              ListTile(
//                title: Text(S.of(context).server),
//                trailing: DropdownButtonHideUnderline(
//                  child: DropdownButton<String>(
//                    value: db.userData.users[db.userData.curUsername].server ??
//                        GameServer.jp,
//                    items: <DropdownMenuItem<String>>[
//                      DropdownMenuItem(
//                        value: GameServer.cn,
//                        child: Text(S.of(context).server_cn),
//                      ),
//                      DropdownMenuItem(
//                        value: GameServer.jp,
//                        child: Text(S.of(context).server_jp),
//                      )
//                    ],
//                    onChanged: (v) {
//                      db.userData.users[db.userData.curUsername].server = v;
//                      db.onAppUpdate();
//                    },
//                  ),
//                ),
//              ),
              ListTile(
                title: Text(S.of(context).cur_account),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      db.userData.users[db.userData.curUserKey].name,
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
              ListTile(
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
              if (kDebugMode)
                ListTile(
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
            ],
          ),
          TileGroup(
            header: S.of(context).settings_general,
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).settings_language),
                trailing: DropdownButton<Language>(
                  underline: Divider(thickness: 0, color: Colors.transparent),
                  value: Language.getLanguage(
                      db.userData.language ?? Language.currentLocaleCode),
                  items: Language.supportLanguages.map((lang) {
                    return DropdownMenuItem(
                        value: lang, child: Text(lang.name));
                  }).toList(),
                  onChanged: (lang) {
                    db.userData.language = lang.code;
                    db.saveUserData();
                    db.onAppUpdate();
                  },
                ),
              ),
              if (Platform.isAndroid || Platform.isIOS)
                SwitchListTile.adaptive(
                  title: Text(S.of(context).settings_use_mobile_network),
                  value: db.userData.useMobileNetwork ?? false,
                  onChanged: (v) async {
                    db.userData.useMobileNetwork = v;
                    db.saveUserData();
                    setState(() {});
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
              if (kDebugMode)
                ListTile(
                  title: Text('Generate Error'),
                  onTap: () {
                    throw FormatException('generated error');
                  },
                )
            ],
          ),
          if (kDebugMode_)
            TileGroup(
              header: 'Test(debug mode: ${kDebugMode_ ? 'on' : 'off'})',
              children: <Widget>[
                ListTile(
                  title: Text('Master-Detail width'),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: db.userData.criticalWidth ?? 768,
                      items: <DropdownMenuItem<double>>[
                        DropdownMenuItem(value: 768, child: Text('768')),
                        DropdownMenuItem(value: 600, child: Text('600'))
                      ],
                      onChanged: (v) {
                        db.userData.criticalWidth = v;
                        db.onAppUpdate();
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

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}
