import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/constants.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> {
  SpecifiedLocalizationDelegate _localOverrideDelegate;

  void onDataChange({Locale locale}) {
    setState(() {
      if (null != locale) {
        _localOverrideDelegate =
            SpecifiedLocalizationDelegate(locale ?? Locale('zh'));
      }
      db.saveAppData();
    });
  }

  @override
  void initState() {
    // update anything after db.initial()!!!
    db.initial().then((_) {
      db.onDataChange = this.onDataChange;
      db.loadUserData().then((_) {
        setState(() {
          if (LangCode.codes.contains(db.appData.language)) {
            _localOverrideDelegate = SpecifiedLocalizationDelegate(
                LangCode.getLocale(db.appData.language));
          }
          //check/initial data
          if (null == db.appData.users || 0 == db.appData.users.length) {
            // create default account
            final name = "default";
            db.appData
              ..curUser = name
              ..users = {name: User(name: name, server: GameServer.cn)};
          }
        });
      });
      //load and extract icons
      db.loadZipAssets('res/data/icons.zip', dir: 'icons');
    });
    //use default before db.initial() and db.load***
    _localOverrideDelegate = SpecifiedLocalizationDelegate(Locale('zh', ''));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chaldea",
      localizationsDelegates: [
        _localOverrideDelegate,
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: db.appData == null
          ? BlankPage()
          : HomePage(), //pass a function for exit button with context
    );
  }
}
