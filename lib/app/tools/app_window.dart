import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'backup_backend/chaldea_backend.dart';

class AppWindowUtil {
  const AppWindowUtil._();
  static bool _trayInstalled = false;

  static Future<void> init() async {
    if (PlatformU.isDesktop) {
      await windowManager.ensureInitialized();
      windowManager.setTitle(kAppName);
      windowManager.setMinimumSize(kDebugMode ? const Size(100, 100) : const Size(375, 568));
      // windowManager.setMaximumSize(Size.infinite); // ?
      windowManager.setPreventClose(true);
    }
  }

  /// window ops

  static Future<void> minimizeWindow() async {
    if (PlatformU.isWindows) {
      return windowManager.hide();
    } else if (PlatformU.isMacOS) {
      return windowManager.minimize();
    } else if (PlatformU.isLinux) {
      return windowManager.minimize();
    }
  }

  static Future<void> showWindow() async {
    if (PlatformU.isDesktop) {
      return windowManager.show();
    }
  }

  static Future<void> destroyWindow() async {
    if (kDebugMode) {
      final confirm = await SimpleCancelOkDialog(
        title: Text(S.current.general_close),
      ).showDialog(kAppKey.currentContext!);
      if (confirm != true) return;
    }
    windowManager.destroy();
  }

  static Future<void> setAlwaysOnTop([bool? onTop]) async {
    if (PlatformU.isDesktop) {
      onTop ??= db.settings.alwaysOnTop;
      windowManager.setAlwaysOnTop(onTop);
    }
  }

  /// tray ops

  static Future<void> toggleTray([bool? value]) {
    if (value != null) {
      return value ? setTray() : destroyTray();
    } else {
      return _trayInstalled ? destroyTray() : setTray();
    }
  }

  @protected
  static Future<void> destroyTray() async {
    if (_trayInstalled) {
      _trayInstalled = false;
      return trayManager.destroy();
    }
  }

  static Future<void> setTray() async {
    if (!PlatformU.isDesktop) return;
    try {
      final icon = 'res/img/launcher_icon/${PlatformU.isWindows ? 'app_icon.ico' : 'app_icon_rounded.png'}';
      trayManager.setIcon(icon);
      final _menuMain = Menu(items: [
        MenuItem(
          label: '$kAppName v${AppInfo.versionString}',
          disabled: true,
        ),
        MenuItem.separator(),
        MenuItem(
          label: S.current.show,
          onClick: (menuItem) => showWindow(),
        ),
        MenuItem.separator(),
        MenuItem(
          label: S.current.hide,
          onClick: (menuItem) => minimizeWindow(),
        ),
        MenuItem.separator(),
        MenuItem(
          label: S.current.quit,
          onClick: (menuItem) async {
            await db.saveAll();
            if (await _shouldCloseCheckUpload()) {
              await destroyWindow();
            }
          },
        ),
      ]);

      await trayManager.setContextMenu(_menuMain);
      print('set tray menu');
      _trayInstalled = true;
    } catch (e, s) {
      logger.e('init system tray failed', e, s);
      EasyLoading.showError('${S.current.failed}: ${S.current.show_system_tray}');
    }
  }

  /// events

  static Future<void> onTrayClick() async {
    if (PlatformU.isWindows) {
      return windowManager.show();
    } else if (PlatformU.isMacOS) {
      return trayManager.popUpContextMenu();
    } else if (PlatformU.isLinux) {
      return windowManager.show();
      // not supported
      // trayManager.popUpContextMenu();
    }
  }

  static Future<void> onTrayRightClick() async {
    if (PlatformU.isWindows) {
      return trayManager.popUpContextMenu();
    } else if (PlatformU.isMacOS) {
      return windowManager.show();
    } else if (PlatformU.isLinux) {
      return windowManager.show();
    }
  }

  static Future<void> onWindowClose() async {
    await db.saveAll();
    if (db.settings.showSystemTray) {
      await minimizeWindow();
      return;
    }
    if (await _shouldCloseCheckUpload()) {
      await destroyWindow();
    }
  }

  // close window if return true
  static Future<bool> _shouldCloseCheckUpload() async {
    logger.i('closing desktop app...');
    if (!db.settings.alertUploadUserData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }

    final visible = await windowManager.isVisible();
    if (!visible) await windowManager.show();

    final ctx = kAppKey.currentContext;
    if (ctx == null || !ctx.mounted) return true;

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
              bool success;
              if (kDebugMode) {
                success = true;
              } else {
                success = await ChaldeaServerBackup().backup();
              }
              if (success && context.mounted) Navigator.pop(context, true);
            },
            child: Text(S.current.upload_and_close_app),
          ),
        ],
      ),
    );
    return close == true;
  }
}
