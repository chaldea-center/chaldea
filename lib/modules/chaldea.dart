import 'dart:io';

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
    SplitRoute.defaultMasterFillPageBuilder = (context) => BlankPage();
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
      locale: Language.getLanguage(db.userData?.language)?.locale ??
          Language.chs.locale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: EasyLoading.init(builder: (context, widget) {
        Catcher.addDefaultErrorWidget(showStacktrace: true);
        return widget;
      }),
      home: _ChaldeaHome(),
    );
  }
}

class _ChaldeaHome extends StatefulWidget {
  @override
  _ChaldeaHomeState createState() => _ChaldeaHomeState();
}

class _ChaldeaHomeState extends State<_ChaldeaHome> with AfterLayoutMixin {
  bool _initiated = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    /// if app updated, check version and reload gamedata
    await db.initial();
    await AppInfo.resolve();
    bool gameDataLoadSuccess =
        File(db.paths.gameDataFilepath).existsSync() && db.loadGameData();
    if (!gameDataLoadSuccess ||
        AppInfo.buildNumber > (db.userData.previousBuildNumber ?? 0)) {
      /// load failed(json destroyed) or app updated, reload default dataset
      // TODO: if asset not exist? download from server
      logger.i('reload default gamedata asset');
      await db.loadZipAssets(kDatasetAssetKey);
      db.userData.previousBuildNumber = AppInfo.buildNumber;
      db.loadGameData();
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
    db.itemStat.update();
    db.checkNetwork();
    _initiated = true;
    setState(() {});
    logger.i('App version: ${AppInfo.appName} v${AppInfo.fullVersion}');
    logger.i('appPath: ${db.paths.appPath}');
    db.onAppUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return _initiated ? HomePage() : BlankPage();
  }
}
