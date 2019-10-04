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

  void onAppUpdate() {
    setState(() {
      final locale = LangCode.getLocale(db.appData.language ?? LangCode.chs);
      _localOverrideDelegate = SpecifiedLocalizationDelegate(locale);
      db.saveData(app: true);
    });
  }

  Future<Null> initial() async {
    await db.initial();
    db.onAppUpdate = this.onAppUpdate;
    await db.loadData(app: true, user: true, game: false);
    await db.loadZipAssets('res/data/dataset.zip',
        dir: db.appData.gameDataPath);
    await db.loadData(app: false, user: false, game: true);
  }

  @override
  void initState() {
    // update anything after initial()!!!
    initial().then((_) {
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
    //use default before data loaded***
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
