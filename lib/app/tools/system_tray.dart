import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:system_tray/system_tray.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';

class SystemTrayUtil {
  const SystemTrayUtil._();
  static final AppWindow appWindow = AppWindow();
  static final SystemTray _systemTray = SystemTray();
  static final Menu _menuMain = Menu();

  static bool _installed = false;

  static String _getIcon() {
    String name = PlatformU.isWindows ? 'app_icon.ico' : 'app_icon_rounded.png';
    return 'res/img/launcher_icon/$name';
  }

  static Future<void> toggle([bool? value]) {
    if (value != null) {
      return value ? init() : destroy();
    } else {
      return _installed ? destroy() : init();
    }
  }

  static Future<void> destroy() async {
    if (_installed) {
      _installed = false;
      return _systemTray.destroy();
    }
  }

  static Future<void> init() async {
    if (!PlatformU.isDesktop) return;
    try {
      await _systemTray.initSystemTray(iconPath: _getIcon());
      // _systemTray.setTitle(kAppName);
      _systemTray.registerSystemTrayEventHandler((eventName) {
        debugPrint("eventName: $eventName");
        if (eventName == kSystemTrayEventClick) {
          PlatformU.isWindows ? appWindow.show() : _systemTray.popUpContextMenu();
        } else if (eventName == kSystemTrayEventRightClick) {
          PlatformU.isWindows ? _systemTray.popUpContextMenu() : appWindow.show();
        }
      });

      await _menuMain.buildFrom([
        MenuItemLabel(label: '$kAppName v${AppInfo.versionString}', enabled: false),
        MenuSeparator(),
        MenuItemLabel(label: S.current.show, onClicked: (menuItem) => appWindow.show()),
        MenuItemLabel(label: S.current.hide, onClicked: (menuItem) => appWindow.hide()),
        MenuItemLabel(
          label: S.current.quit,
          onClicked: (menuItem) async {
            await db.saveAll();
            appWindow.close();
          },
        ),
      ]);
      _systemTray.setContextMenu(_menuMain);
      _installed = true;
    } catch (e, s) {
      logger.e('init system tray failed', e, s);
      EasyLoading.showError('${S.current.failed}: ${S.current.show_system_tray}');
    }
  }
}
