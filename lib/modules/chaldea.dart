import 'dart:io';

import 'package:catcher/core/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:flutter/services.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: MaterialApp(
        title: kAppName,
        debugShowCheckedModeBanner: false,
        navigatorKey: kAppKey,
        locale: Language.getLanguage(db.userData?.language)?.locale,
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
      ),
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
    bool gameDataLoadSuccess = false;
    try {
      await db.initial();
      await AppInfo.resolve();
      if (AppInfo.buildNumber > (db.userData.previousBuildNumber ?? 0) ||
          !File(db.paths.gameDataFilepath).existsSync() ||
          !db.loadGameData()) {
        /// load failed(json destroyed) or app updated, reload default dataset
        // TODO: if asset not exist? download from server
        logger.i('reload default gamedata asset');
        await db.loadZipAssets(kDatasetAssetKey);
        db.userData.previousBuildNumber = AppInfo.buildNumber;
        gameDataLoadSuccess = db.loadGameData();
      } else {
        gameDataLoadSuccess = true;
      }
      db.checkNetwork();
    } catch (e, s) {
      logger.e('initiate app error.', e, s);
    }
    if (!gameDataLoadSuccess) {
      showInformDialog(context, title: '加载数据错误', content: '请在设置中重新加载默认数据');
    }
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
