import 'dart:async';
import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:chaldea/components/bdtj.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:chaldea/components/shared_prefs.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> with AfterLayoutMixin {
  String? userdataBackup;

  _ChaldeaState();

  @override
  void afterFirstLayout(BuildContext context) async {
    if (Platform.isAndroid) {
      final String externalBackupDir =
          join('/storage/emulated/0/backup', kPackageName, 'user');
      if (!(await Permission.storage.isGranted)) {
        var confirmed = await SimpleCancelOkDialog(
          title: Text('Storage Permission'),
          content: Text('用户数据备份储存于临时目录(${db.paths.userDir})\n'
              '删除应用(及后续计划构建号变更升级时！)将导致备份消失，建议开启储存访问权限以备份至($externalBackupDir})\n'
              'Android 11用户需要额外在权限设置里"允许管理所有文件"'),
        ).show(kAppKey.currentContext!);
        if (confirmed == true) {
          logger.i('request storage permission');
          await Permission.storage.request();
        }
      }
      logger.d('storage permission: ${await Permission.storage.status}');
      if(await Permission.storage.isGranted) {
        db.paths.userDataExternalBackup = externalBackupDir;
      }
    }

    // if failed to load userdata, backup and alert user
    if (File(db.paths.userDataPath).existsSync() && !db.loadUserData()) {
      userdataBackup = db.backupUserdata();
    }

    if (userdataBackup != null) {
      showInformDialog(
        kAppKey.currentContext!,
        title: 'Userdata damaged',
        content: 'A backup is created:\n $userdataBackup',
      );
    }
    Future.delayed(Duration(seconds: 5)).then((_) => reportBdtj());
  }

  @override
  void initState() {
    super.initState();
    db.runtimeData.screenshotController = ScreenshotController();
    SplitRoute.defaultMasterFillPageBuilder = (context) => BlankPage();
    db.notifyAppUpdate = () {
      setPreferredOrientations();
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
    setPreferredOrientations();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Screenshot(
        controller: db.runtimeData.screenshotController!,
        child: MaterialApp(
          title: kAppName,
          debugShowCheckedModeBanner: false,
          navigatorKey: kAppKey,
          locale: Language.getLanguage(db.userData.language)?.locale,
          localizationsDelegates: [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
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

  void setPreferredOrientations() {
    if (!AppInfo.isMobile) return;
    if (db.userData.autorotate) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([]);
    }
  }
}

class _ChaldeaHome extends StatefulWidget {
  @override
  _ChaldeaHomeState createState() => _ChaldeaHomeState();
}

class _ChaldeaHomeState extends State<_ChaldeaHome> with AfterLayoutMixin {
  bool _initiated = false;
  bool _showProgress = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    // ensure image is shown on screen
    await precacheImage(AssetImage("res/img/chaldea.png"), context);
    await Future.delayed(Duration(milliseconds: 100));

    // if app updated, reload gamedata
    bool gameDataLoadSuccess = false;
    final previousVersion = Version.tryParse(
        db.prefs.instance.getString(SharedPrefs.previousVersion) ?? '');
    bool justUpdated =
        previousVersion == null || previousVersion < AppInfo.versionClass;
    try {
      if (justUpdated ||
          !File(db.paths.gameDataPath).existsSync() ||
          !db.loadGameData()) {
        /// load failed(json destroyed) or app updated, reload default dataset
        // TODO: if asset not exist? download from server
        logger.i('reload default gamedata asset');
        setState(() {
          _showProgress = true;
        });
        await db.loadZipAssets(kDatasetAssetKey);
        db.prefs.instance
            .setString(SharedPrefs.previousVersion, AppInfo.fullVersion);
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
    db.notifyAppUpdate();
    if (justUpdated) {
      GitTool.fromDb().appReleaseNote().then((releaseNote) {
        if (releaseNote?.isNotEmpty == true) {
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            SimpleCancelOkDialog(
              title: Text(AppInfo.fullVersion2),
              content: Text(releaseNote!.replaceAll('\r\n', '\n')),
              hideCancel: true,
            ).show(kAppKey.currentContext!);
          });
        }
      }).onError((error, stackTrace) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _initiated
        ? HomePage()
        : BlankPage(showProgress: _showProgress, reserveProgressSpace: true);
  }
}
