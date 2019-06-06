import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatype/constants.dart';
import 'package:chaldea/modules/home/settings_item.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:chaldea/modules/home/subpage/lang_page.dart';
import 'package:flutter/cupertino.dart';
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
                    value: db.data.users[db.data.curUser].server,
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
                    onChanged: (v){
                      db.data.users[db.data.curUser].server=v;
                      db.onDataChange();
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(S.of(context).cur_account),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(db.data.users[db.data.curUser].name,style: TextStyle(color: Colors.black87),),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
                onTap: (){
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
                    Text(LangCode.getName(language) ?? "",style: TextStyle(color: Colors.black87),),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
                onTap: (){
                  SplitRoute.popAndPush(context, builder: (context)=>LanguagePage());
                },
              )
            ],
          ),
          TileGroup(
            header: S.of(context).backup_restore,
            tiles: <Widget>[
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
}
