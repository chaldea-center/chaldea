import 'dart:ui' show Size;

import 'package:tray_manager/tray_manager.dart'
    show
        ImageAsset,
        Menu,
        MenuItem,
        MenuItemClickedEvent,
        MenuItemType,
        TrayIcon,
        TrayIconClickedEvent,
        TrayIconDoubleClickedEvent,
        TrayIconPosition,
        TrayIconRightClickedEvent;

import 'package:chaldea/packages/platform/platform.dart';

/// Desktop system tray built on tray_manager's native API.
///
/// This file must never be reachable from a web build: tray_manager 0.7 is
/// backed by nativeapi, whose dart:ffi bindings are not available on the web,
/// so [tray_controller_stub.dart] is used there instead.
class TrayController {
  TrayController({required this.onShow, required this.onHide, required this.onQuit});

  final Future<void> Function() onShow;
  final Future<void> Function() onHide;
  final Future<void> Function() onQuit;

  // nativeapi wrappers release their native handle when collected, which would
  // remove the tray icon or a menu entry, so keep every wrapper referenced for
  // as long as the tray is shown.
  TrayIcon? _trayIcon;
  Menu? _menu;
  final List<MenuItem> _menuItems = <MenuItem>[];

  bool get installed => _trayIcon != null;

  Future<void> install({
    required String iconPath,
    required String versionLabel,
    required String showLabel,
    required String hideLabel,
    required String quitLabel,
  }) async {
    if (installed) await uninstall();

    final trayIcon = TrayIcon.create();
    if (trayIcon == null) throw StateError('Unable to create the tray icon');

    final icon = ImageAsset.fromAsset(iconPath);
    if (icon == null) throw ArgumentError.value(iconPath, 'iconPath', 'Unable to load tray icon');

    trayIcon
      ..icon = icon
      ..isIconTemplate = false
      ..iconSize = const Size.square(18)
      ..iconPosition = TrayIconPosition.left;

    final menu = Menu.create();
    if (menu == null) throw StateError('Unable to create the tray menu');

    MenuItem addMenuItem(String label, {bool enabled = true, Future<void> Function()? onClick}) {
      final item = MenuItem.createWithLabelAndType(label, MenuItemType.normal);
      if (item == null) throw StateError('Unable to create the tray menu item: $label');
      item.isEnabled = enabled;
      if (onClick != null) {
        item.addListener((event) {
          if (event is MenuItemClickedEvent) onClick();
        });
      }
      menu.addItem(item);
      _menuItems.add(item);
      return item;
    }

    addMenuItem(versionLabel, enabled: false);
    menu.addSeparator();
    addMenuItem(showLabel, onClick: onShow);
    menu.addSeparator();
    addMenuItem(hideLabel, onClick: onHide);
    menu.addSeparator();
    addMenuItem(quitLabel, onClick: onQuit);

    trayIcon.setContextMenu(menu);
    trayIcon.setVisible(true);

    // nativeapi reports a whole click at once and nothing at all on Linux,
    // where the panel keeps the click and opens the menu itself.
    trayIcon.addListener((event) {
      switch (event) {
        case TrayIconClickedEvent():
          _onIconClick();
        case TrayIconRightClickedEvent():
          _onIconRightClick();
        case TrayIconDoubleClickedEvent():
          break;
      }
    });

    _trayIcon = trayIcon;
    _menu = menu;
  }

  Future<void> uninstall() async {
    for (final item in _menuItems) {
      item.dispose();
    }
    _menuItems.clear();
    _menu?.dispose();
    _menu = null;
    _trayIcon?.dispose();
    _trayIcon = null;
  }

  void _onIconClick() {
    if (PlatformU.isWindows || PlatformU.isLinux) {
      onShow();
    } else if (PlatformU.isMacOS) {
      openMenu();
    }
  }

  void _onIconRightClick() {
    if (PlatformU.isWindows) {
      openMenu();
    } else if (PlatformU.isMacOS || PlatformU.isLinux) {
      onShow();
    }
  }

  void openMenu() => _trayIcon?.openContextMenu();
}
