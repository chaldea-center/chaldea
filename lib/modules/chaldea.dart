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
  Locale locale;

  void onAppUpdate() {
    setState(() {
      locale=LangCode.getLocale(db?.appData?.language);
    });
  }

  Future<Null> initial() async {
    await db.initial();
    db.onAppUpdate = this.onAppUpdate;
    await db.loadData(app: true, game: false);
    await db.loadZipAssets('res/data/dataset.zip',
        dir: db.appData.gameDataPath);
    await db.loadData(app: false, game: true);
  }

  @override
  void initState() {
    // update anything after initial()!!!
    super.initState();
    initial().then((_) {
      onAppUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      title: "Chaldea",
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback: S.delegate.resolution(fallback: Locale('zh','')),
      home: db.appData == null ? BlankPage() : HomePage(), //pass a function for exit button with context
    );
  }
}
