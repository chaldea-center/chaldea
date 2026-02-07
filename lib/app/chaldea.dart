import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/tools/app_update.dart';
import 'package:chaldea/generated/intl/messages_all.dart';
import 'package:chaldea/models/faker/shared/network.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/home_widget.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../generated/l10n.dart';
import '../models/db.dart';
import '../packages/ads/ads.dart';
import '../packages/language.dart';
import '../packages/method_channel/method_channel_chaldea.dart';
import '../packages/network.dart';
import '../packages/platform/platform.dart';
import 'app.dart';
import 'routes/parser.dart';
import 'tools/app_window.dart';

class Chaldea extends StatefulWidget {
  Chaldea({super.key});

  @override
  _ChaldeaState createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> with AfterLayoutMixin, WindowListener, TrayListener {
  final routeInformationParser = AppRouteInformationParser();
  final backButtonDispatcher = RootBackButtonDispatcher();

  @override
  void reassemble() {
    super.reassemble();
    reloadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = _getThemeData(dark: false);
    final darkTheme = _getThemeData(dark: true);
    Widget child = Screenshot(
      controller: db.runtimeData.screenshotController,
      child: MaterialApp.router(
        title: kAppName,
        onGenerateTitle: (_) => kAppName,
        routeInformationParser: routeInformationParser,
        routerDelegate: rootRouter,
        backButtonDispatcher: backButtonDispatcher,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: db.settings.themeMode,
        scrollBehavior: DraggableScrollBehavior(enableMouse: db.settings.enableMouseDrag),
        locale: Language.getLanguage(db.settings.language)?.locale,
        localizationsDelegates: const [S.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: Language.getSortedSupportedLanguage(db.settings.language).map((e) => e.locale),
        builder: (context, widget) {
          ErrorWidget.builder = _ErrorWidget.errorWidgetBuilder;
          return FlutterEasyLoading(child: widget);
        },
      ),
    );
    if (PlatformU.isAndroid) {
      child = AnnotatedRegion<SystemUiOverlayStyle>(
        value: db.settings.isResolvedDarkMode
            ? SystemUiOverlayStyle.dark.copyWith(
                // statusBarColor: Colors.transparent,
                systemNavigationBarColor: darkTheme.scaffoldBackgroundColor,
                // statusBarIconBrightness: Brightness.light,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.light.copyWith(
                // statusBarColor: Colors.transparent,
                systemNavigationBarColor: lightTheme.scaffoldBackgroundColor,
                // statusBarIconBrightness: Brightness.dark,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        child: child,
      );
    }
    return child;
  }

  ThemeData _getThemeData({required bool dark}) {
    final themeData = ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      useMaterial3: db.settings.useMaterial3,
      colorSchemeSeed: db.settings.colorSeed?.color,
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
    );
    return themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(
        titleSpacing: 0,
        toolbarHeight: 48, // kToolbarHeight=56,
      ),
      listTileTheme: themeData.listTileTheme.copyWith(minLeadingWidth: 24),
    );
  }

  void onAppUpdate() {
    for (final _router in rootRouter.appState.children) {
      _router.forceRebuild();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // debugPrint('initiate $runtimeType');
    super.initState();
    db.notifyAppUpdate = onAppUpdate;
    db.settings.launchTimes += 1;
    if (db.settings.language != null) {
      Intl.defaultLocale = Language.current.code;
    }

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      // debugPrint('SystemChannels> $msg');
      if (msg == AppLifecycleState.resumed.toString()) {
        // Actions when app is resumed
        network.check();
      } else if (msg == AppLifecycleState.inactive.toString()) {
        db.saveAll();
        if (NetworkManagerBase.hasCalled) {
          try {
            await HomeWidgetX.saveFakerStatus();
            await HomeWidgetX.updateFakerStatus();
          } catch (e, s) {
            print(e);
            print(s);
          }
        }
        // debugPrint('save userdata before being inactive');
      }
      return null;
    });

    windowManager.addListener(this);
    trayManager.addListener(this);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    AppWindowUtil.setAlwaysOnTop();
    if (PlatformU.isWindows) {
      MethodChannelChaldea.setWindowPos();
    }
    AppAds.init();

    if (DateTime.now().timestamp - db.settings.lastBackup > 24 * 3600) {
      db.backupUserdata();
      db.backupSettings();
    }
    if (PlatformU.isMobile && !AppInfo.isIPad) {
      if (!db.settings.autoRotate) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    }

    if (db.settings.showSystemTray) AppWindowUtil.setTray();

    CachedApi.remoteConfig();
    if (db.settings.autoUpdateApp &&
        !kIsWeb &&
        (DateTime.now().timestamp - db.settings.lastLaunchTime > 7 * kSecsPerDay || db.settings.launchTimes % 5 == 0)) {
      await Future.delayed(const Duration(seconds: 5));
      if (PlatformU.isIOS) {
        AppUpdater.checkAppStoreUpdate();
      } else if (PlatformU.isAndroid) {
        if (AppInfo.isFDroid) {
          // skip
        } else {
          AppUpdater.backgroundUpdate();
        }
      } else if (PlatformU.isWindows || PlatformU.isLinux) {
        AppUpdater.backgroundUpdate();
      }
    }
    db.settings.lastLaunchTime = DateTime.now().timestamp;

    FilePickerU.clearTemporaryFiles();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    AppWindowUtil.onWindowClose();
  }

  @override
  void onTrayIconMouseDown() {
    AppWindowUtil.onTrayClick();
  }

  @override
  void onTrayIconRightMouseDown() {
    AppWindowUtil.onTrayRightClick();
  }
}

class DraggableScrollBehavior extends MaterialScrollBehavior {
  final bool enableMouse;
  const DraggableScrollBehavior({this.enableMouse = true});
  @override
  Set<PointerDeviceKind> get dragDevices => {
    for (final v in PointerDeviceKind.values)
      if (v != PointerDeviceKind.mouse || enableMouse) v,
  };
}

class _ErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _ErrorWidget(this.details);

  static Widget errorWidgetBuilder(FlutterErrorDetails details) => _ErrorWidget(details);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final nav = Navigator.maybeOf(context);
          if (nav == null) return;
          if (nav.canPop()) nav.pop();
        },
        onLongPress: () {
          final nav = Navigator.maybeOf(context);
          if (nav == null) return;
          nav.push(
            PageRouteBuilder(
              pageBuilder: (context, _, _) {
                return Scaffold(
                  appBar: AppBar(title: Text(S.current.error)),
                  body: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      const DividerWithTitle(title: 'URL'),
                      Text(router.currentConfiguration?.url ?? 'Unknown'),
                      const DividerWithTitle(title: 'Error'),
                      Text(details.exception.toString()),
                      if (details.stack != null) ...[
                        const DividerWithTitle(title: 'StackTrace'),
                        Text(details.stack.toString(), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
        child: Text.rich(
          TextSpan(
            children: [
              const WidgetSpan(child: Icon(Icons.announcement, color: Colors.red, size: 40)),
              TextSpan(text: '\n${S.current.error_widget_hint}'),
            ],
          ),
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
