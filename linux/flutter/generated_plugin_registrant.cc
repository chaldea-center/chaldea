//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <catcher/catcher_plugin.h>
#include <flutter_qjs/flutter_qjs_plugin.h>
#include <flutter_window_close/flutter_window_close_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>
#include <window_size/window_size_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) catcher_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "CatcherPlugin");
  catcher_plugin_register_with_registrar(catcher_registrar);
  g_autoptr(FlPluginRegistrar) flutter_qjs_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterQjsPlugin");
  flutter_qjs_plugin_register_with_registrar(flutter_qjs_registrar);
  g_autoptr(FlPluginRegistrar) flutter_window_close_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterWindowClosePlugin");
  flutter_window_close_plugin_register_with_registrar(flutter_window_close_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
  g_autoptr(FlPluginRegistrar) window_size_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowSizePlugin");
  window_size_plugin_register_with_registrar(window_size_registrar);
}
