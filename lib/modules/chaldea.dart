import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screenshot/screenshot.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> with AfterLayoutMixin {
  String userdataBackup;

  _ChaldeaState() {
    if (File(db.paths.userDataPath).existsSync() && !db.loadUserData()) {
      userdataBackup = db.backupUserdata();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (userdataBackup != null) {
      showInformDialog(
        kAppKey.currentContext,
        title: 'Userdata damaged',
        content: 'A backup is created:\n $userdataBackup',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    db.screenshotController = ScreenshotController();
    SplitRoute.defaultMasterFillPageBuilder = (context) => BlankPage();
    db.onAppUpdate = () {
      setState(() {});
    };
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      debugPrint('SystemChannels> $msg');
      if (msg == AppLifecycleState.resumed.toString()) {
        // Actions when app is resumed
        db.checkConnectivity();
      } else if (msg == AppLifecycleState.inactive.toString()) {
        db.saveUserData();
        debugPrint('save userdata before being inactive');
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Screenshot(
        controller: db.screenshotController,
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
          builder: (context, widget) {
            Catcher.addDefaultErrorWidget(showStacktrace: true);
            return FlutterEasyLoading(child: widget);
          },
          home: _ChaldeaHome(),
        ),
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
      if (AppInfo.buildNumber > (db.userData.previousBuildNumber ?? 0) ||
          !File(db.paths.gameDataPath).existsSync() ||
          !db.loadGameData()) {
        /// load failed(json destroyed) or app updated, reload default dataset
        // TODO: if asset not exist? download from server
        logger.i('reload default gamedata asset');
        await db.loadZipAssets(kDatasetAssetKey);
        db.userData.previousBuildNumber = AppInfo.buildNumber;
        db.saveUserData();
        gameDataLoadSuccess = db.loadGameData();
      } else {
        gameDataLoadSuccess = true;
      }
    } catch (e, s) {
      logger.e('initiate app error.', e, s);
    }
    if (!gameDataLoadSuccess) {
      showInformDialog(context, title: '加载数据错误', content: '请尝试在设置中重新加载默认数据');
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
