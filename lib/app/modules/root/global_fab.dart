import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/_test_page.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/movable_fab.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import '../misc/theme_palette.dart';

class WindowManagerFab extends StatefulWidget {
  const WindowManagerFab({super.key});

  @override
  _WindowManagerFabState createState() => _WindowManagerFabState();

  static GlobalKey<_WindowManagerFabState> globalKey = GlobalKey();
  static OverlayEntry? _instance;

  static void createOverlay(BuildContext context) {
    context = router.navigatorKey.currentContext ?? context;
    _instance?.remove();
    _instance =
        OverlayEntry(builder: (context) => WindowManagerFab(key: globalKey));
    Overlay.of(context, rootOverlay: true)?.insert(_instance!);
  }

  static void removeOverlay() {
    _instance?.remove();
    _instance = null;
  }

  static void markNeedRebuild() {
    _instance?.markNeedsBuild();
  }
}

class _WindowManagerFabState extends State<WindowManagerFab> {
  @override
  Widget build(BuildContext context) {
    return MovableFab(
      icon: Icon(
        rootRouter.appState.showWindowManager ? Icons.reply : Icons.grid_view,
        size: 20,
      ),
      onPressed: () {
        setState(() {
          rootRouter.appState.showWindowManager =
              !rootRouter.appState.showWindowManager;
        });
      },
    );
  }
}

class DebugFab extends StatefulWidget {
  const DebugFab({super.key});

  @override
  _DebugFabState createState() => _DebugFabState();

  static GlobalKey<_DebugFabState> globalKey = GlobalKey();
  static OverlayEntry? _instance;

  static void createOverlay(BuildContext context) {
    _instance?.remove();
    _instance = OverlayEntry(builder: (context) => DebugFab(key: globalKey));
    Overlay.of(context, rootOverlay: true)?.insert(_instance!);
  }

  static void removeOverlay() {
    _instance?.remove();
    _instance = null;
  }
}

class _DebugFabState extends State<DebugFab> {
  bool isMenuShowing = false;
  double opacity = 0.75;

  @override
  Widget build(BuildContext context) {
    return MovableFab(
      icon: const Icon(Icons.menu_open, size: 20),
      initialY: 0.9,
      opacity: opacity,
      enabled: !isMenuShowing,
      backgroundColor: isMenuShowing ? Theme.of(context).disabledColor : null,
      onPressed: () {
        setState(() {
          isMenuShowing = true;
        });
        final context = rootRouter.navigatorKey.currentContext;
        if (context == null) return;
        showDialog(
          context: context,
          builder: (context) => _DebugMenuDialog(state: this),
        ).then((value) {
          isMenuShowing = false;
          if (mounted) setState(() {});
        });
      },
    );
  }

  void hide([int seconds = 60]) {
    opacity = 0;
    if (mounted) {
      setState(() {});
    }
    Future.delayed(Duration(seconds: seconds), () {
      opacity = 0.75;
      if (mounted) {
        setState(() {});
      }
    });
  }
}

class _DebugMenuDialog extends StatefulWidget {
  final _DebugFabState? state;

  const _DebugMenuDialog({this.state});

  @override
  __DebugMenuDialogState createState() => __DebugMenuDialogState();
}

class __DebugMenuDialogState extends State<_DebugMenuDialog> {
  bool get enableScreenshot => !kIsWeb || kPlatformMethods.rendererCanvasKit;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(S.current.debug_menu),
      children: [
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: Text(S.current.toggle_dark_mode),
          horizontalTitleGap: 0,
          onTap: () {
            Navigator.pop(context);
            db.settings.themeMode = db.settings.isResolvedDarkMode
                ? ThemeMode.light
                : ThemeMode.dark;
            db.notifyAppUpdate();
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(S.current.settings_language),
          horizontalTitleGap: 0,
          trailing: DropdownButton<Language>(
            underline: const Divider(thickness: 0, color: Colors.transparent),
            value: Language.getLanguage(db.settings.language),
            items: Language.supportLanguages
                .map((lang) =>
                    DropdownMenuItem(value: lang, child: Text(lang.name)))
                .toList(),
            onChanged: (lang) {
              if (lang == null) return;
              db.settings.setLanguage(lang);
              db.notifyAppUpdate();
            },
          ),
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.color_lens_outlined),
          title: const Text('Palette'),
          onTap: () {
            Navigator.pop(context);
            router.pushPage(DarkLightThemePalette());
          },
        ),
        ListTile(
          leading: const Icon(Icons.screenshot_monitor),
          title: Text(S.current.screenshots),
          subtitle: enableScreenshot
              ? null
              : const Text('Only available in canvaskit renderer'),
          horizontalTitleGap: 0,
          enabled: enableScreenshot,
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => const _ScreenshotDialog(),
            );
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.timer),
          title: const Text('Hide 60s'),
          onTap: () {
            widget.state?.hide(60);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Reload GameData'),
          onTap: () async {
            EasyLoading.show();
            final data = await GameDataLoader.instance.reload(force: true);
            if (data != null) db.gameData = data;
            EasyLoading.dismiss();
            EasyLoading.showSuccess(S.current.update_msg_succuss);
          },
        ),
        ListTile(
          title: const Text('Init ItemCenter'),
          onTap: () {
            db.gameData.preprocess();
            db.itemCenter.init();
          },
        ),
        if (!kReleaseMode)
          ListTile(
            title: const Text('TestFunc'),
            onTap: () => testFunction(context),
          ),
        ListTile(
          title: const Text('Save User Data'),
          onTap: () {
            db.saveAll();
            Navigator.pop(context);
          },
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}

class _ScreenshotDialog extends StatefulWidget {
  const _ScreenshotDialog();

  @override
  State<_ScreenshotDialog> createState() => __ScreenshotDialogState();
}

class __ScreenshotDialogState extends State<_ScreenshotDialog> {
  late double ratio = MediaQuery.of(context).devicePixelRatio;
  @override
  Widget build(BuildContext context) {
    final dftRatio = MediaQuery.of(context).devicePixelRatio;
    final minRatio = (dftRatio * 2.5).toInt() / 10,
        maxRatio = (dftRatio * 50).toInt() / 10;
    ratio = ratio.clamp(minRatio, maxRatio);
    return SimpleCancelOkDialog(
      title: Text(S.current.screenshots),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Device Pixel Ratio'),
            subtitle: Text('${S.current.general_default}: $dftRatio'),
            trailing: Text(ratio.toStringAsFixed(1)),
            contentPadding: EdgeInsets.zero,
          ),
          Slider.adaptive(
            value: ratio,
            min: minRatio,
            max: maxRatio,
            divisions: (maxRatio - minRatio) ~/ 0.1 + 1,
            label: ratio.toStringAsFixed(1),
            onChanged: (v) {
              setState(() {
                ratio = v;
              });
            },
          ),
          Text('3s delay', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      scrollable: true,
      confirmText: S.current.screenshots,
      onTapOk: () async {
        await EasyLoading.showInfo('Ready',
            duration: const Duration(seconds: 1));
        await Future.delayed(const Duration(seconds: 3));
        try {
          final data = await db.runtimeData.screenshotController
              .capture(pixelRatio: ratio);
          if (data == null) {
            EasyLoading.showError(S.current.failed);
            return;
          }
          await ImageActions.showSaveShare(
            context: kAppKey.currentContext!,
            data: data,
            destFp: joinPaths(db.paths.downloadDir,
                'screenshot-${DateTime.now().toSafeFileName()}.png'),
          );
        } catch (e, s) {
          logger.e('take screenshot failed', e, s);
          EasyLoading.showError('${S.current.failed}\n$e');
        }
      },
    );
  }
}
