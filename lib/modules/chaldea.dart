import 'package:after_layout/after_layout.dart';
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
  @override
  void initState() {
    super.initState();
    db.onAppUpdate = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chaldea",
      debugShowCheckedModeBanner: false,
      navigatorKey: Catcher.navigatorKey,
      locale: Language.getLanguage(db.userData?.language)?.locale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, widget) {
        Catcher.addDefaultErrorWidget(showStacktrace: true);
        return widget;
      },
      home: _ChaldeaHome(),
    );
  }
}

class _ChaldeaHome extends StatefulWidget {
  @override
  __ChaldeaHomeState createState() => __ChaldeaHomeState();
}

class __ChaldeaHomeState extends State<_ChaldeaHome> with AfterLayoutMixin {
  bool _initiated = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    await db.initial();
    print(db.paths.appPath);
    if (!db.loadGameData()) {
      await db.loadZipAssets(kDatasetAssetKey);
      // await SimpleCancelOkDialog(
      //   title: Text('资源不存在或已损坏'),
      //   content: Text('是否重新下载?'),
      //   onTapOk: () async {
      //     await db.downloadGameData();
      //     db.itemStat.update();
      //     setState(() {});
      //   },
      // ).show(context);
    }
    db.loadUserData();
    db.itemStat.update();
    db.checkNetwork();
    _initiated = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _initiated ? HomePage() : BlankPage();
  }
}
