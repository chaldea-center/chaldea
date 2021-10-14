//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <catcher/catcher_plugin.h>
#include <connectivity_plus_windows/connectivity_plus_windows_plugin.h>
#include <flutter_qjs/flutter_qjs_plugin.h>
#include <libwinmedia/libwinmedia_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  CatcherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CatcherPlugin"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FlutterQjsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterQjsPlugin"));
  LibwinmediaPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LibwinmediaPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
