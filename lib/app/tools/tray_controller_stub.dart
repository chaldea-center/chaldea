/// No-op fallback for platforms without a system tray (the web).
///
/// tray_manager 0.7 is backed by nativeapi, whose dart:ffi bindings cannot be
/// compiled for the web, so web builds resolve the tray controller to this stub
/// instead of [tray_controller_native.dart]. It is never installed because
/// `PlatformU.isDesktop` is always false on the web.
class TrayController {
  TrayController({required this.onShow, required this.onHide, required this.onQuit});

  final Future<void> Function() onShow;
  final Future<void> Function() onHide;
  final Future<void> Function() onQuit;

  bool get installed => false;

  Future<void> install({
    required String iconPath,
    required String versionLabel,
    required String showLabel,
    required String hideLabel,
    required String quitLabel,
  }) async {}

  Future<void> uninstall() async {}
}
