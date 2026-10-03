import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:window_manager/window_manager.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'backup_backend/chaldea_backend.dart';
import 'tray_controller_stub.dart' if (dart.library.ffi) 'tray_controller_native.dart';

/// Window and system-tray helpers.
///
/// The tray controller is imported conditionally: tray_manager 0.7 is backed by
/// nativeapi, whose dart:ffi bindings cannot be compiled for the web, so the web
/// build resolves the tray controller to a no-op stub.
class AppWindowUtil {
  const AppWindowUtil._();
  static TrayController? _tray;

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
      return (_tray?.installed ?? false) ? destroyTray() : setTray();
    }
  }

  @protected
  static Future<void> destroyTray() async {
    final tray = _tray;
    _tray = null;
    await tray?.uninstall();
  }

  static Future<void> setTray() async {
    if (!PlatformU.isDesktop) return;
    try {
      await destroyTray();
      final tray = TrayController(onShow: showWindow, onHide: minimizeWindow, onQuit: _quitFromTray);
      await tray.install(
        iconPath: 'res/img/launcher_icon/${PlatformU.isWindows ? 'app_icon.ico' : 'app_icon_rounded.png'}',
        versionLabel: '$kAppName v${AppInfo.versionString}',
        showLabel: S.current.show,
        hideLabel: S.current.hide,
        quitLabel: S.current.quit,
      );
      _tray = tray;
      print('set tray menu');
    } catch (e, s) {
      logger.e('init system tray failed', e, s);
      EasyLoading.showError('${S.current.failed}: ${S.current.show_system_tray}');
    }
  }

  static Future<void> _quitFromTray() async {
    await db.saveAll();
    if (await _shouldCloseCheckUpload()) {
      await destroyWindow();
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
