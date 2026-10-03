import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tray_manager/tray_manager.dart' hide Image;
import 'package:window_manager/window_manager.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'backup_backend/chaldea_backend.dart';

class AppWindowUtil {
  const AppWindowUtil._();
  static bool _trayInstalled = false;
  static TrayIcon? _trayIcon;
  static Menu? _trayMenu;
  static final List<MenuItem> _trayMenuItems = <MenuItem>[];

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
      final confirm = await SimpleConfirmDialog(title: Text(S.current.general_close))
          .showDialog(kAppKey.currentContext!);
      if (confirm != true) return;
    }
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
    exit(0);
  }

  static Future<void> setAlwaysOnTop([bool? onTop]) async {
    if (PlatformU.isDesktop) {
      onTop ??= db.settings.platform.alwaysOnTop;
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
    if (!_trayInstalled) return;
    _trayInstalled = false;
    for (final item in _trayMenuItems) {
      item.dispose();
    }
    _trayMenuItems.clear();
    _trayMenu?.dispose();
    _trayMenu = null;
    _trayIcon?.dispose();
    _trayIcon = null;
  }

  static Future<void> setTray() async {
    if (!PlatformU.isDesktop) return;
    try {
      if (_trayInstalled) await destroyTray();

      final trayIcon = TrayIcon.create();
      if (trayIcon == null) throw StateError('Unable to create the tray icon');

      final iconPath = 'res/img/launcher_icon/${PlatformU.isWindows ? 'app_icon.ico' : 'app_icon_rounded.png'}';
      final icon = ImageAsset.fromAsset(iconPath);
      if (icon == null) throw ArgumentError.value(iconPath, 'iconPath', 'Unable to load tray icon');

      trayIcon
        ..icon = icon
        ..isIconTemplate = false
        ..iconSize = const Size.square(18)
        ..iconPosition = TrayIconPosition.left;

      final menu = Menu.create();
      if (menu == null) throw StateError('Unable to create the tray menu');
      final menuItems = <MenuItem>[];

      MenuItem addMenuItem(String label, {bool enabled = true, void Function()? onClick}) {
        final item = MenuItem.createWithLabelAndType(label, MenuItemType.normal);
        if (item == null) throw StateError('Unable to create the tray menu item: $label');
        item.isEnabled = enabled;
        if (onClick != null) {
          item.addListener((event) {
            if (event is MenuItemClickedEvent) onClick();
          });
        }
        menu.addItem(item);
        menuItems.add(item);
        return item;
      }

      addMenuItem('$kAppName v${AppInfo.versionString}', enabled: false);
      menu.addSeparator();
      addMenuItem(S.current.show, onClick: () => showWindow());
      menu.addSeparator();
      addMenuItem(S.current.hide, onClick: () => minimizeWindow());
      menu.addSeparator();
      addMenuItem(
        S.current.quit,
        onClick: () async {
          await db.saveAll();
          if (await _shouldCloseCheckUpload()) {
            await destroyWindow();
          }
        },
      );

      trayIcon.setContextMenu(menu);
      trayIcon.setVisible(true);

      // nativeapi reports a whole click at once and nothing at all on Linux,
      // where the panel keeps the click and opens the menu itself.
      trayIcon.addListener((event) {
        switch (event) {
          case TrayIconClickedEvent():
            onTrayClick();
          case TrayIconRightClickedEvent():
            onTrayRightClick();
          case TrayIconDoubleClickedEvent():
            break;
        }
      });

      _trayIcon = trayIcon;
      _trayMenu = menu;
      _trayMenuItems.addAll(menuItems);
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
      await windowManager.show();
    } else if (PlatformU.isMacOS) {
      _trayIcon?.openContextMenu();
    } else if (PlatformU.isLinux) {
      await windowManager.show();
      // not supported
      // _trayIcon?.openContextMenu();
    }
  }

  static Future<void> onTrayRightClick() async {
    if (PlatformU.isWindows) {
      _trayIcon?.openContextMenu();
    } else if (PlatformU.isMacOS) {
      await windowManager.show();
    } else if (PlatformU.isLinux) {
      await windowManager.show();
    }
  }

  static Future<void> onWindowClose() async {
    await db.saveAll();
    if (db.settings.platform.showSystemTray) {
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
    final alertUploadUserData = db.settings.network.alertUploadUserData && kDebugMode;
    if (!alertUploadUserData) {
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
