import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/constants.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:chaldea/modules/home/subpage/lang_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String language;
  String user;

  @override
  Widget build(BuildContext context) {
    language = S.of(context).language;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings_tab_name),
      ),
      backgroundColor: MyColors.setting_bg,
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: S.of(context).settings_data,
            tiles: <Widget>[
              ListTile(
                title: Text(S.of(context).settings_tutorial),
                trailing: null,
              ),
              ListTile(
                title: Text(S.of(context).server),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: db.appData.users[db.appData.curUserName].server??'cn',
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: GameServer.cn,
                        child: Text(S.of(context).server_cn),
                      ),
                      DropdownMenuItem(
                        value: GameServer.jp,
                        child: Text(S.of(context).server_jp),
                      )
                    ],
                    onChanged: (v) {
                      db.appData.users[db.appData.curUserName].server = v;
                      db.onAppUpdate();
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(S.of(context).cur_account),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      db.appData.users[db.appData.curUserName].name,
                      style: TextStyle(color: Colors.black87),
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => AccountPage());
                },
              ),
            ],
          ),
          TileGroup(
            header: S.of(context).settings_general,
            tiles: <Widget>[
              ListTile(
                title: Text(S.of(context).settings_language),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      S.of(context).language,
                      style: TextStyle(color: Colors.black87),
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => LanguagePage());
                },
              )
            ],
          ),
          TileGroup(
            header: S.of(context).backup_restore,
            tiles: <Widget>[
              ListTile(
                title: Text('Master-Detail width'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: db.appData.criticalWidth??768,
                    items: <DropdownMenuItem<double>>[
                      DropdownMenuItem(
                        value: 768,
                        child: Text('768'),
                      ),
                      DropdownMenuItem(
                        value: 600,
                        child: Text('600'),
                      )
                    ],
                    onChanged: (v) {
                      setState(() {
                        db.appData.criticalWidth = v;
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text('Extract dataset'),
                onTap: () async {
                  await db.loadZipAssets('res/data/dataset.zip',
                      forceLoad: true);
                  await db.loadData();
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('dataset have been extracted.')));
                },
              ),
              ListTile(
                title: Text('clear all data'),
                onTap: () {
                  db.clearData(app: true, game: true).then((_) =>
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('userdata cleared'))));
                },
              ),
              ListTile(
                title: Text('Reload app/user/game data'),
                onTap: () {
                  db.loadData().then((_) {
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('load finish.')));
                  });
                },
              ),
              ListTile(
                title: Text(S.of(context).backup),
              ),
              ListTile(
                title: Text(S.of(context).restore),
              )
            ],
          )
        ],
      ),
    );
  }


  @override
  void deactivate() {
    super.deactivate();
    db.saveData();
  }
}
