import 'package:catcher/core/catcher.dart';
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
      title: "Chaldea",
      debugShowCheckedModeBanner: false,
      navigatorKey: Catcher.navigatorKey,
      locale: LangCode.getLocale(db.userData?.language),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeResolutionCallback:
          S.delegate.resolution(fallback: Locale('zh', '')),
      builder: (context, widget) {
        // TODO: error widget not shown? blank page only.
        Catcher.addDefaultErrorWidget(
            showStacktrace: false,
            customTitle: "Custom error title",
            customDescription: "Custom error description");
        return widget;
      },
      home: db.userData == null ? BlankPage(showProgress: true) : HomePage(),
    );
  }
}
