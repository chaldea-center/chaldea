import 'dart:async';

import 'package:chaldea/components/analytics.dart';
import 'package:chaldea/components/catcher_util/catcher_config.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:chaldea/modules/home/subpage/support_donation_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screenshot/screenshot.dart';

import '404.dart';
import 'cmd_code/cmd_code_detail_page.dart';
import 'craft/craft_detail_page.dart';
import 'debug/debug_floating_menu.dart';
import 'servant/costume_detail_page.dart';
import 'servant/servant_detail_page.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> with AfterLayoutMixin {
  List<String>? userdataBackup;
  final GlobalKey<_ChaldeaHomeState> _homeKey = GlobalKey();

  _ChaldeaState();

  @override
  void reassemble() {
    super.reassemble();
  }

  void onAppUpdate() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (!mounted) return;
      _homeKey.currentState?._onAppUpdate();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    db.notifyAppUpdate = onAppUpdate;
    db.runtimeData.screenshotController = ScreenshotController();
    SplitRoute.defaultMasterFillPageBuilder = (context) => BlankPage();

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

    LicenseRegistry.addLicense(() async* {
      Map<String, String> licenses = {
        'MOONCELL': 'doc/license/CC-BY-NC-SA-4.0.txt',
        'FANDOM': 'doc/license/CC-BY-SA-3.0.txt',
        'Atlas Academy': 'doc/license/ODC-BY 1.0.txt',
      };
      for (final entry in licenses.entries) {
        String license =
            await rootBundle.loadString(entry.value).catchError((e, s) async {
          logger.e('load license(${entry.key}, ${entry.value}) failed.', e, s);
          return 'load license failed';
        });
        yield LicenseEntryWithLineBreaks([entry.key], license);
      }
    });

    // if failed to load userdata, backup and alert user
    if (File(db.paths.userDataPath).existsSync() && !db.loadUserData()) {
      userdataBackup = db.backupUserdata(disk: true, memory: false);
    }

    if (userdataBackup != null) {
      Utils.scheduleFrameCallback(() {
        showInformDialog(
          kAppKey.currentContext!,
          title: 'Userdata damaged',
          content: 'A backup is created:\n ${userdataBackup!.join('\n')}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = configureTheme(ThemeData.light());
    final darkTheme = configureTheme(ThemeData.dark());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: db.appSetting.isResolvedDarkMode
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: darkTheme.scaffoldBackgroundColor)
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: lightTheme.scaffoldBackgroundColor),
      child: Screenshot(
        controller: db.runtimeData.screenshotController!,
        child: MaterialApp(
          title: kAppName,
          debugShowCheckedModeBanner: false,
          navigatorKey: kAppKey,
          themeMode: db.appSetting.themeMode ?? ThemeMode.system,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          locale: Language.getLanguage(db.appSetting.language)?.locale,
          localizationsDelegates: [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: S.delegate.supportedLocales,
          scrollBehavior: DraggableScrollBehavior(),
          builder: (context, widget) {
            ErrorWidget.builder = CatcherUtility.errorWidgetBuilder;
            return FlutterEasyLoading(child: widget);
          },
          // let the initial route '/' become a SplitRoute
          onGenerateInitialRoutes: (String initialRouteName) {
            return [
              SplitRoute(
                builder: (context, _) => _ChaldeaHome(key: _homeKey),
                detail: false,
              )
            ];
          },
          onGenerateRoute: onGenerateRoute,
          onUnknownRoute: (settings) {
            return SplitRoute(
              builder: (context, _) => Route404Page(settings: settings),
              detail: true,
            );
          },
        ),
      ),
    );
  }

  ThemeData configureTheme(ThemeData themeData) {
    return themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(titleSpacing: 0),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (Platform.isMacOS || Platform.isWindows) {
      MethodChannelChaldea.setAlwaysOnTop();
    }
    if (Platform.isWindows) {
      MethodChannelChaldea.setWindowPos();
    }

    if (!Analyzer.skipReport()) {
      await Future.delayed(Duration(seconds: 5));
      await Analyzer.sendStat();
      await Analyzer.sendBdtj();
    }
  }

  /// In carousel link, prefix /chaldea/route
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    logger.d('onGenerateRoute: $settings');
    if (settings.name == null) return null;
    List<String> segments =
        settings.name!.split('/').where((e) => e.isNotEmpty).toList();
    if (segments.length == 2 && segments[0] == 'servant') {
      final svt = db.gameData.servants[int.tryParse(segments[1])];
      if (svt != null)
        return SplitRoute(
          builder: (_, __) => ServantDetailPage(svt),
          detail: true,
        );
    } else if (segments.length == 2 && segments[0] == 'craft_essence') {
      final craft = db.gameData.crafts[int.tryParse(segments[1])];
      if (craft != null)
        return SplitRoute(
          builder: (_, __) => CraftDetailPage(ce: craft),
          detail: true,
        );
    } else if (segments.length == 2 && segments[0] == 'command_code') {
      final code = db.gameData.cmdCodes[int.tryParse(segments[1])];
      if (code != null)
        return SplitRoute(
          builder: (_, __) => CmdCodeDetailPage(code: code),
          detail: true,
        );
    } else if (segments.length == 2 && segments[0] == 'costume') {
      final costume = db.gameData.costumes[int.tryParse(segments[1])];
      if (costume != null)
        return SplitRoute(
          builder: (_, __) => CostumeDetailPage(costume: costume),
          detail: true,
        );
    } else if (segments.isNotEmpty && segments.first == 'support') {
      return SplitRoute(
        builder: (_, __) => SupportDonationPage(),
        detail: true,
      );
    }
    return null;
  }
}

class _ChaldeaHome extends StatefulWidget {
  _ChaldeaHome({Key? key}) : super(key: key);

  @override
  _ChaldeaHomeState createState() => _ChaldeaHomeState();
}

class _ChaldeaHomeState extends State<_ChaldeaHome> with AfterLayoutMixin {
  bool _initiated = false;
  bool _showProgress = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    // ensure image is shown on screen
    await precacheImage(AssetImage("res/img/chaldea.png"), context,
        onError: (e, s) {
      logger.w('pre cache chaldea image error', e, s);
    });
    await Future.delayed(Duration(milliseconds: 100));

    // if app updated, reload gamedata
    bool gameDataLoadSuccess = false;
    final previousVersion =
        Version.tryParse(db.prefs.previousVersion.get() ?? '');
    bool justUpdated =
        previousVersion == null || previousVersion < AppInfo.versionClass;
    try {
      if (justUpdated ||
          !File(db.paths.gameDataPath).existsSync() ||
          !db.loadGameData()) {
        db.backupUserdata(disk: true, memory: false);

        /// load failed(json destroyed) or app updated, reload default dataset
        logger.i('reload default gamedata asset');
        setState(() {
          _showProgress = true;
        });
        await db.loadZipAssets(kDatasetAssetKey);
        db.prefs.previousVersion.set(AppInfo.fullVersion);
        db.saveUserData();
        gameDataLoadSuccess = db.loadGameData();
      } else {
        gameDataLoadSuccess = true;
      }
    } catch (e, s) {
      logger.e('initiate app error.', e, s);
    }
    if (!gameDataLoadSuccess) {
      showInformDialog(context,
          title: S.current.load_dataset_error,
          content: S.current.load_dataset_error_hint);
    }
    _initiated = true;
    if (mounted) setState(() {});
    logger.i('App version: ${AppInfo.appName} v${AppInfo.fullVersion}');
    logger.i('appPath: ${db.paths.appPath}');
    db.notifyAppUpdate();
    // macOS审核太啰嗦了
    if (justUpdated && !AppInfo.isMacStoreApp) {
      GitTool.fromDb().appReleaseNote().then((releaseNote) {
        if (releaseNote?.isNotEmpty == true) {
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            SimpleCancelOkDialog(
              title: Text(AppInfo.version),
              content: Text(releaseNote!.replaceAll('\r\n', '\n')),
              hideCancel: true,
              scrollable: true,
            ).showDialog(kAppKey.currentContext!);
          });
        }
      }).onError((error, stackTrace) => null);
    }
    if (db.runtimeData.showDebugFAB)
      DebugFloatingMenuButton.createOverlay(context);
  }

  /// place some operations that need a [MaterialApp] like ancestor
  /// e.g. [MediaQuery.of]
  void _onAppUpdate() {
    if (!mounted) return;
    setPreferredOrientations();
  }

  @override
  void didUpdateWidget(covariant _ChaldeaHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    // usually resize
    DebugFloatingMenuButton.globalKey.currentState?.markNeedRebuild();
  }

  @override
  Widget build(BuildContext context) {
    return _initiated
        ? HomePage()
        : BlankPage(showProgress: _showProgress, reserveProgressSpace: true);
  }

  /// only set orientation for mobile phone
  void setPreferredOrientations() {
    if (!AppInfo.isMobile || AppInfo.isIPad) return;
    if (!db.appSetting.autorotate) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([]);
    }
  }
}

class DraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
