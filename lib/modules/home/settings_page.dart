import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatype/constants.dart';
import 'package:chaldea/modules/home/detail.dart';
import 'package:chaldea/modules/home/settings_item.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:chaldea/modules/home/subpage/lang_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _switchOn = false;
  String language;
  String user;

  @override
  Widget build(BuildContext context) {
    language = S.of(context).language;
    if (null == db.data.users || 0 == db.data.users.length) {
      // create default account
      final name = "default";
      db.data
        ..curUser = name
        ..users = {name: User(id: name, server: 'cn')};
    }
    final tileTheme = ListTileTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings_tab_name),
      ),
      backgroundColor: AppColor.setting_bg,
      body: ListView(
        children: <Widget>[
          SGroup(
            header: S.of(context).settings_data,
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).settings_tutorial),
                trailing: null,
              ),
              SWidget(
                label: S.of(context).settings_tutorial,
              ),
              SModal(
                label: S.of(context).cur_account,
                value: db.data.curUser,
                callback: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => AccountPage());
                },
              )
            ],
          ),
          SGroup(
            header: S.of(context).settings_general,
            footer: "This is a footer.",
            children: <Widget>[
              SModal(
                label: S.of(context).settings_language,
                value: LangCode.getName(language) ?? "",
                callback: () {
                  SplitRoute.popAndPush(context, builder: (context) {
                    return LanguagePage();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
