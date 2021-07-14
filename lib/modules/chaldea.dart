import 'dart:async';

import 'package:chaldea/components/analytics.dart';
import 'package:chaldea/components/catcher_util/catcher_config.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screenshot/screenshot.dart';

import 'debug/debug_floating_menu.dart';

class Chaldea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> with AfterLayoutMixin {
  List<String>? userdataBackup;
  final GlobalKey<_ChaldeaHomeState> _homeKey = GlobalKey();

  _ChaldeaState();

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
        'MOONCELL': 'res/licenses/CC-BY-NC-SA-4.0',
        'FANDOM': 'res/licenses/CC-BY-SA-3.0',
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
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();

    Color? navColor;
    switch (db.userData.themeMode) {
      case ThemeMode.light:
        navColor = lightTheme.scaffoldBackgroundColor;
        break;
      case ThemeMode.dark:
        navColor = darkTheme.scaffoldBackgroundColor;
        break;
      default:
        if (SchedulerBinding.instance!.window.platformBrightness ==
            Brightness.light) {
          navColor = lightTheme.scaffoldBackgroundColor;
        } else {
          navColor = darkTheme.scaffoldBackgroundColor;
        }
        break;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: navColor,
      ),
      child: Screenshot(
        controller: db.runtimeData.screenshotController!,
        child: MaterialApp(
          title: kAppName,
          debugShowCheckedModeBanner: false,
          navigatorKey: kAppKey,
          themeMode: db.userData.themeMode ?? ThemeMode.system,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          locale: Language.getLanguage(db.userData.language)?.locale,
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
          home: _ChaldeaHome(key: _homeKey),
        ),
      ),
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
              title: Text(AppInfo.fullVersion),
              content: Text(releaseNote!.replaceAll('\r\n', '\n')),
              hideCancel: true,
              scrollable: true,
            ).showDialog(kAppKey.currentContext!);
          });
        }
      }).onError((error, stackTrace) => null);
    }
    _createFloatingBtn();
  }

  /// place some operations that need a [MaterialApp] like ancestor
  /// e.g. [MediaQuery.of]
  void _onAppUpdate() {
    if (!mounted) return;
    setPreferredOrientations();
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
    if (db.userData.autorotate && SplitRoute.isSplit(context)) {
      SystemChrome.setPreferredOrientations([]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  OverlayEntry? _floatingBtnEntry;

  void _createFloatingBtn() {
    if (kReleaseMode) return;
    _floatingBtnEntry ??= OverlayEntry(
      builder: (context) => DebugFloatingMenuButton(),
    );
    Overlay.of(context)!.insert(_floatingBtnEntry!);
  }
}

class DraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
