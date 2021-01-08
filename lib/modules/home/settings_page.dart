import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/dataset_manage_page.dart';
import 'package:flutter/foundation.dart';

import 'subpage/about_page.dart';
import 'subpage/account_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String language;
  String user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    language = S.of(context).language;
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
                title: Text('数据管理'),
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
            ],
          ),
          TileGroup(
            header: S.of(context).settings_general,
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).settings_language),
                trailing: DropdownButton<Language>(
                    underline: Divider(thickness: 0, color: Colors.transparent),
                    value: Language.getLanguage(S.of(context).language) ??
                        Language.getLanguage(),
                    items: Language.languages.map((lang) {
                      return DropdownMenuItem(
                          value: lang, child: Text(lang.name));
                    }).toList(),
                    onChanged: (lang) {
                      db.userData.language = lang.code;
                      db.onAppUpdate();
                    }),
              ),
              SwitchListTile.adaptive(
                  title: Text('使用移动数据下载'),
                  value: db.userData.useMobileNetwork ?? false,
                  onChanged: (v) async {
                    db.userData.useMobileNetwork = v;
                    await db.checkNetwork();
                    setState(() {});
                  }),
            ],
          ),
          TileGroup(
            header: 'About',
            children: <Widget>[
              ListTile(
                title: Text('关于Chaldea'),
                onTap: () => SplitRoute.push(
                  context: context,
                  builder: (context, _) => AboutPage(),
                  popDetail: true,
                ),
              ),
            ],
          ),
          if (kDebugMode)
            TileGroup(
              header: 'Test(debug mode: ${kDebugMode ? 'on' : 'off'})',
              children: <Widget>[
                SwitchListTile.adaptive(
                    title: Text('允许下载'),
                    value: db.userData.testAllowDownload ?? true,
                    onChanged: (v) async {
                      db.userData.testAllowDownload = v;
                      await db.checkNetwork();
                      setState(() {});
                    }),
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
