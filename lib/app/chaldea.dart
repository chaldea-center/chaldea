import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/tools/app_update.dart';
import 'package:chaldea/generated/intl/messages_all.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../generated/l10n.dart';
import '../models/db.dart';
import '../packages/language.dart';
import '../packages/logger.dart';
import '../packages/method_channel/method_channel_chaldea.dart';
import '../packages/network.dart';
import '../packages/platform/platform.dart';
import '../utils/catcher/catcher_util.dart';
import '../widgets/after_layout.dart';
import 'app.dart';
import 'routes/parser.dart';
import 'tools/backup_backend/chaldea_backend.dart';

class Chaldea extends StatefulWidget {
  Chaldea({Key? key}) : super(key: key);

  @override
  _ChaldeaState createState() => _ChaldeaState();
}

class _ChaldeaState extends State<Chaldea> with AfterLayoutMixin {
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
        scrollBehavior: DraggableScrollBehavior(),
        locale: Language.getLanguage(db.settings.language)?.locale,
        localizationsDelegates: const [
          S.delegate,
          ...GlobalMaterialLocalizations.delegates
        ],
        supportedLocales:
            Language.getSortedSupportedLanguage(db.settings.language)
                .map((e) => e.locale),
        builder: (context, widget) {
          ErrorWidget.builder = CatcherUtil.errorWidgetBuilder;
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
    var themeData = dark
        ? ThemeData(brightness: Brightness.dark)
        : ThemeData(brightness: Brightness.light);
    return themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(
        titleSpacing: 0,
        toolbarHeight: 48, // kToolbarHeight=56,
        titleTextStyle: kIsWeb
            ? null
            : (themeData.appBarTheme.titleTextStyle ?? const TextStyle())
                .copyWith(fontSize: 20),
      ),
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
      debugPrint('SystemChannels> $msg');
      if (msg == AppLifecycleState.resumed.toString()) {
        // Actions when app is resumed
        network.check();
      } else if (msg == AppLifecycleState.inactive.toString()) {
        db.saveAll();
        debugPrint('save userdata before being inactive');
      }
      return null;
    });

    setOnWindowClose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (PlatformU.isWindows || PlatformU.isMacOS) {
      MethodChannelChaldeaNext.setAlwaysOnTop();
    }
    if (PlatformU.isWindows) {
      MethodChannelChaldeaNext.setWindowPos();
    }
    if (DateTime.now().timestamp - db.settings.lastBackup > 24 * 3600) {
      db.backupUserdata();
    }
    if (PlatformU.isMobile && !AppInfo.isIPad) {
      if (!db.settings.autoRotate) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    }

    if (db.settings.autoUpdateApp && !kIsWeb) {
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
  }

  void setOnWindowClose() {
    if (!PlatformU.isDesktop) return;
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      logger.i('closing desktop app...');
      await db.saveAll();
      if (!db.settings.alertUploadUserData) {
        await Future.delayed(const Duration(milliseconds: 200));
        return true;
      }
      return _alertUpload();
    });
  }

  Future<bool> _alertUpload() async {
    final ctx = kAppKey.currentContext;
    if (ctx == null) return true;
    final close = await showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        content: Text(S.current.upload_and_close_app_alert),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(S.current.general_close),
          ),
          TextButton(
            onPressed: () async {
              final success = await ChaldeaServerBackup().backup();
              if (success && mounted) Navigator.pop(context, true);
            },
            child: Text(S.current.upload_and_close_app),
          ),
        ],
      ),
    );
    return close == true;
  }
}

class DraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
