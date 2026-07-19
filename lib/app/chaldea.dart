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
import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/api/jwt_utils.dart';
import 'package:chaldea/app/tools/app_update.dart';
import 'package:chaldea/generated/intl/messages_all.dart';
import 'package:chaldea/models/faker/shared/network.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/home_widget.dart';
import 'package:chaldea/packages/logger.dart';
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
import 'modules/auth/change_email_page.dart';
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

  // In-memory flag: suppresses the email binding prompt for the rest of this
  // app session after the user dismisses it once. Resets on cold restart.
  bool _emailBindingSkipped = false;

  @override
  void reassemble() {
    super.reassemble();
    reloadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = AppTheme.light();
    final darkTheme = AppTheme.dark();
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

    // Silent migration of legacy Worker tokens runs in the background after the
    // first frame. No overlay/mask — users can interact with the app while it
    // runs. On success with an empty email, an email-binding prompt is shown.
    unawaited(_trySilentMigration());

    // Proactively rotate the JWT if it is within 7 days of expiry. Failures
    // are silent — passive refresh on 401 covers the edge case.
    unawaited(_tryProactiveRefresh());

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

  /// Best-effort silent migration of legacy Worker session secrets to JWT.
  ///
  /// Runs in the background after the first frame. On any failure (network,
  /// 5xx, parse error) the app continues silently. On 401 the local legacy
  /// secret is cleared (handled inside `maybeMigrateLegacyToken`). On success,
  /// if the migrated user has no email bound, a skippable prompt is shown.
  Future<void> _trySilentMigration() async {
    try {
      final user = await ChaldeaServerApi.maybeMigrateLegacyToken();
      if (user == null) return;
      if (user.email == null || user.email!.isEmpty) {
        _showEmailBindingPrompt();
      }
    } catch (e, s) {
      // Swallow — migration is best-effort and must never block the UI.
      logger.d('Silent migration failed (silent): $e', e, s);
    }
  }

  /// Proactively rotates the JWT on app startup if it is within 7 days of
  /// expiry. Best-effort — failures are silent (passive refresh on 401
  /// covers the edge case where a token expires mid-session).
  Future<void> _tryProactiveRefresh() async {
    try {
      final token = db.settings.secrets.user.accessToken;
      if (token == null || token.isEmpty) return;
      final remaining = JwtUtils.remainingTime(token);
      if (remaining == null || remaining <= Duration.zero) {
        // Invalid or expired token — clear and persist
        // db.settings.secrets.user.accessToken = null;
        // await db.saveSettings();
        return;
      }
      if (remaining < const Duration(days: 7)) {
        final user = await ChaldeaServerApi.refreshToken();
        if (user != null && user.accessToken.isNotEmpty) {
          db.settings.secrets.user.updateFromLoginResponse(user);
          await db.saveAll();
        }
        // Refresh failed — silent, runtime 401 will handle
      }
    } catch (e, s) {
      logger.d('Proactive refresh failed (silent): $e', e, s);
    }
  }

  /// Show a skippable dialog prompting the user to bind an email.
  /// Suppressed for the rest of the session once dismissed.
  void _showEmailBindingPrompt() {
    if (_emailBindingSkipped) return;
    final context = rootRouter.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(Language.isZH ? '绑定邮箱' : 'Bind Email'),
          content: Text(
            Language.isZH
                ? '您尚未绑定邮箱。未绑定邮箱时：\n\n'
                      '• 忘记密码后无法通过邮箱找回，需联系管理员手动重置\n'
                      '• 可能错过重要的服务器通知\n\n'
                      '建议尽快绑定邮箱以保障账号安全。'
                : 'You have not bound an email yet. Without an email:\n\n'
                      '• Password recovery is impossible if forgotten — you must contact admin for manual reset\n'
                      '• You may miss critical server notifications\n\n'
                      'Binding an email is strongly recommended for account security.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _emailBindingSkipped = true;
              },
              child: Text(Language.isZH ? '稍后再说' : 'Later'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _emailBindingSkipped = true;
                router.push(child: const ChangeEmailPage());
              },
              child: Text(Language.isZH ? '去绑定' : 'Bind Now'),
            ),
          ],
        );
      },
    );
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
