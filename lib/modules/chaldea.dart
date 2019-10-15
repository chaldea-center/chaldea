import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> {
  void onAppUpdate() {
    setState(() {});
  }

  Future<Null> initialApp() async {
    await db.initial();
    db.onAppUpdate = this.onAppUpdate;
    await db.loadUserData();
    await db.loadAssetsData('res/data/dataset.zip',
        dir: db.userData.gameDataPath);
    await db.loadGameData();
    setState(() {});
  }

  @override
  void initState() {
    // show anything after data loaded in initial()!!!
    super.initState();
    initialApp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: LangCode.getLocale(db.userData?.language),
      title: "Chaldea",
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback:
          S.delegate.resolution(fallback: Locale('zh', '')),
      home: db.userData == null ? BlankPage() : HomePage(),
    );
  }
}
