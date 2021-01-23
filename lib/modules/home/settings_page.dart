import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/dataset_manage_page.dart';

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
              ListTile(
                title: Text(S.of(context).download_source),
                subtitle: Text(S.of(context).download_source_hint),
                trailing: DropdownButton(
                  value: db.userData.appDatasetUpdateSource ?? 0,
                  items: [
                    DropdownMenuItem(
                        child: Text(S.of(context).download_source_of(1)),
                        value: 0),
                    DropdownMenuItem(
                        child: Text(S.of(context).download_source_of(2)),
                        value: 1),
                  ],
                  onChanged: (v) => setState(() {
                    db.userData.appDatasetUpdateSource = v;
                    db.saveUserData();
                  }),
                ),
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
              SwitchListTile.adaptive(
                  title: Text(S.of(context).settings_use_mobile_network),
                  value: db.userData.useMobileNetwork ?? false,
                  onChanged: (v) async {
                    db.userData.useMobileNetwork = v;
                    await db.checkNetwork();
                    db.saveUserData();
                    setState(() {});
                  }),
            ],
          ),
          TileGroup(
            header: S.of(context).settings_about,
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
            ],
          ),
          if (kDebugMode_)
            TileGroup(
              header: 'Test(debug mode: ${kDebugMode_ ? 'on' : 'off'})',
              children: <Widget>[
                SwitchListTile.adaptive(
                    title: Text('Allow download'),
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
