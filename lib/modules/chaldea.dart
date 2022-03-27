import 'dart:async';

import 'package:chaldea/app/modules/common/blank_page.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/models/version.dart';
import 'package:chaldea/modules/home/home_page.dart';
import 'package:chaldea/modules/home/subpage/support_donation_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screenshot/screenshot.dart';

import '../components/method_channel_chaldea.dart';
import '../generated/intl/messages_all.dart';
import '../packages/network.dart';
import '../utils/catcher/catcher_util.dart';
import 'cmd_code/cmd_code_detail_page.dart';
import 'craft/craft_detail_page.dart';
import 'debug/debug_floating_menu.dart';
import 'route_404.dart';
import 'servant/costume_detail_page.dart';
import 'servant/servant_detail_page.dart';

class Chaldea extends StatefulWidget {
  Chaldea({Key? key}) : super(key: key);

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
    reloadMessages();
  }

  void onAppUpdate() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _homeKey.currentState?._onAppUpdate();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    db.notifyAppUpdate = onAppUpdate;

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      debugPrint('SystemChannels> $msg');
      if (msg == AppLifecycleState.resumed.toString()) {
        // Actions when app is resumed
        network.check();
      } else if (msg == AppLifecycleState.inactive.toString()) {
        db.saveUserData();
        debugPrint('save userdata before being inactive');
      }
      return null;
    });

    // if failed to load userdata, backup and alert user
    if (!PlatformU.isWeb && !db.loadUserData()) {
      if (File(db.paths.userDataPath).existsSync()) {
        userdataBackup = db.backupUserdata(disk: true, memory: false);
      }
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
        controller: db.runtimeData.screenshotController,
        child: MaterialApp(
          title: kAppName,
          debugShowCheckedModeBanner: false,
          navigatorKey: kAppKey,
          themeMode: db.appSetting.themeMode ?? ThemeMode.system,
          theme: lightTheme,
          darkTheme: darkTheme,
          locale: Language.getLanguage(db.appSetting.language)?.locale ??
              Language.en.locale,
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales:
              Language.getSortedSupportedLanguage(db.appSetting.language)
                  .map((e) => e.locale),
          scrollBehavior: DraggableScrollBehavior(),
          builder: (context, widget) {
            ErrorWidget.builder = CatcherUtil.errorWidgetBuilder;
            return FlutterEasyLoading(child: widget);
          },
          // let the initial route '/' become a SplitRoute
          onGenerateInitialRoutes: (String initialRouteName) {
            return [
              SplitRoute(
                builder: (context, _) => _ChaldeaHome(key: _homeKey),
                detail: null,
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
    if (PlatformU.isMacOS || PlatformU.isWindows) {
      MethodChannelChaldea.setAlwaysOnTop();
    }
    if (PlatformU.isWindows) {
      MethodChannelChaldea.setWindowPos();
    }

    // if (!Analyzer.skipReport()) {
    //   await Future.delayed(const Duration(seconds: 5));
    //   await Analyzer.sendStat();
    //   await Analyzer.sendBdtj();
    // }
  }

  /// In carousel link, prefix /chaldea/route
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    logger.d('onGenerateRoute: $settings');
    if (settings.name == null) return null;
    List<String> segments =
        settings.name!.split('/').where((e) => e.isNotEmpty).toList();
    if (segments.length == 2 && segments[0] == 'servant') {
      final svt = db.gameData.servants[int.tryParse(segments[1])];
      if (svt != null) {
        return SplitRoute(
          builder: (_, __) => ServantDetailPage(svt),
          detail: true,
        );
      }
    } else if (segments.length == 2 && segments[0] == 'craft_essence') {
      final craft = db.gameData.crafts[int.tryParse(segments[1])];
      if (craft != null) {
        return SplitRoute(
          builder: (_, __) => CraftDetailPage(ce: craft),
          detail: true,
        );
      }
    } else if (segments.length == 2 && segments[0] == 'command_code') {
      final code = db.gameData.cmdCodes[int.tryParse(segments[1])];
      if (code != null) {
        return SplitRoute(
          builder: (_, __) => CmdCodeDetailPage(code: code),
          detail: true,
        );
      }
    } else if (segments.length == 2 && segments[0] == 'costume') {
      final costume = db.gameData.costumes[int.tryParse(segments[1])];
      if (costume != null) {
        return SplitRoute(
          builder: (_, __) => CostumeDetailPage(costume: costume),
          detail: true,
        );
      }
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
  const _ChaldeaHome({Key? key}) : super(key: key);

  @override
  _ChaldeaHomeState createState() => _ChaldeaHomeState();
}

class _ChaldeaHomeState extends State<_ChaldeaHome> with AfterLayoutMixin {
  bool _initiated = false;
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    db.cfg.launchTimes.set((db.cfg.launchTimes.get() ?? 0) + 1);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    // ensure image is shown on screen
    await precacheImage(const AssetImage("res/img/chaldea.png"), context,
        onError: (e, s) async {
      logger.w('pre cache chaldea image error', e, s);
    });
    await Future.delayed(const Duration(milliseconds: 100));

    // if app updated, reload gamedata
    bool gameDataLoadSuccess = false;
    final previousVersion =
        AppVersion.tryParse(db.prefs.previousVersion.get() ?? '');
    bool justUpdated =
        previousVersion == null || previousVersion < AppInfo.version;

    try {
      if (PlatformU.isWeb) {
        db.webFS!.put(db.paths.hiveAsciiKey(db.paths.gameDataPath),
            await rootBundle.loadString('res/data/dataset.json'));
        gameDataLoadSuccess = await db.loadGameData();
      } else if (justUpdated ||
          !File(db.paths.gameDataPath).existsSync() ||
          !await db.loadGameData()) {
        db.backupUserdata(disk: true, memory: false);

        /// load failed(json destroyed) or app updated, reload default dataset
        logger.i('reload default gamedata asset');
        setState(() {
          _showIndicator = true;
        });
        await db.loadZipAssets(kDatasetAssetKey);
        db.prefs.previousVersion.set(AppInfo.fullVersion);
        db.saveUserData();
        gameDataLoadSuccess = await db.loadGameData();
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

    // set _initiated first, next frame will change layout and child widget together
    _initiated = true;
    SplitRoute.of(context)?.detail = false;

    db.notifyAppUpdate();
    // macOS审核太啰嗦了
    if (justUpdated && !AppInfo.isMacStoreApp) {
      GitTool.fromDb().appReleaseNote().then((releaseNote) {
        if (releaseNote?.isNotEmpty == true) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            SimpleCancelOkDialog(
              title: Text(AppInfo.versionString),
              content: Text(releaseNote!.replaceAll('\r\n', '\n')),
              hideCancel: true,
              scrollable: true,
            ).showDialog(kAppKey.currentContext!);
          });
        }
      }).catchError((error, stackTrace) => Future.value(null));
    }
    if (db.runtimeData.showDebugFAB) {
      DebugFloatingMenuButton.createOverlay(context);
    }
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
    if (_initiated) {
      return HomePage();
    } else if (db.initErrorDetail != null) {
      return BlankPage(
        showIndicator: true,
        indicatorBuilder: (context) {
          final detail = db.initErrorDetail!;
          return Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: RichText(
                text: TextSpan(
                  text: 'Error: ${detail.exception}\n\n',
                  style: Theme.of(context).textTheme.subtitle1,
                  children: [
                    TextSpan(
                      text: detail.stack.toString(),
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
                overflow: TextOverflow.fade,
              )),
            ),
          );
        },
      );
    }
    return BlankPage(showIndicator: _showIndicator);
  }

  /// only set orientation for mobile phone
  void setPreferredOrientations() {
    if (!PlatformU.isMobile || AppInfo.isIPad) return;
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
