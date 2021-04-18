#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(RunLoop* run_loop,
                             const flutter::DartProject& project)
    : run_loop_(run_loop), project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  ConfigMethodChannel(flutter_controller_->engine());
  run_loop_->RegisterFlutterInstance(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    run_loop_->UnregisterFlutterInstance(flutter_controller_->engine());
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opporutunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_EXITSIZEMOVE:
      RECT rect;
      if (chaldea_channel && GetWindowRect(hwnd, &rect)) {
        chaldea_channel->InvokeMethod("onWindowPos", std::unique_ptr<flutter::EncodableValue>(
          new flutter::EncodableValue(
            flutter::EncodableMap({
              {
                flutter::EncodableValue("pos"),
                flutter::EncodableList({
                  flutter::EncodableValue(rect.left),
                  flutter::EncodableValue(rect.top),
                  flutter::EncodableValue(rect.right - rect.left),
                  flutter::EncodableValue(rect.bottom - rect.top)
                })
              }
            }))
          ));
      }
      break;
    case WM_CLOSE:
      // WM_CLOSE then WM_DESTROY
      // std::cout << "[windows] onCloseWindow" << std::endl;
      chaldea_channel->InvokeMethod("onCloseWindow", nullptr);
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::ConfigMethodChannel(flutter::FlutterEngine* engine)
{
  const flutter::StandardMethodCodec& codec = flutter::StandardMethodCodec::GetInstance();
  chaldea_channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(engine->messenger(), "chaldea.narumi.cc/chaldea", &codec);
  chaldea_channel->SetMethodCallHandler([this](
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
      std::cout << "[windows] on call:" << call.method_name() << std::endl;
      auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
      if (call.method_name().compare("alwaysOnTop") == 0) {
        auto encodedOnTop = arguments->find(flutter::EncodableValue("onTop"));
        if (encodedOnTop != arguments->end()) {
          auto onTop = std::get<bool>(encodedOnTop->second);
          std::cout << "[windows] set alwaysOnTop=" << onTop << std::endl;
          auto flag = onTop ? HWND_TOPMOST : HWND_NOTOPMOST;
          SetWindowPos(
            GetHandle(), flag,
            0, 0,
            0, 0,
            SWP_DRAWFRAME | SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
          result->Success(flutter::EncodableValue(true));
        }
        else {
          result->Success(flutter::EncodableValue(false));
        }
      }
      else if (call.method_name().compare("setWindowRect") == 0) {
        auto encodedPos = arguments->find(flutter::EncodableValue("pos"));
        if (encodedPos == arguments->end()) {
          result->Success(nullptr);
        }
        else {
          auto pos = std::get<flutter::EncodableList>(encodedPos->second);
          auto left = std::get<int>(pos[0]);
          auto top = std::get<int>(pos[1]);
          auto width = std::get<int>(pos[2]);
          auto height = std::get<int>(pos[3]);

          RECT desktop;
          if (GetWindowRect(GetDesktopWindow(), &desktop)) {
            int dx = 100;
            int desktop_width = desktop.right - desktop.left;
            int desktop_height = desktop.bottom - desktop.top;
            if (width < dx || width>desktop_width - dx*2) {
              width = desktop_width * 2 / 3;
            }
            if (height<dx || height>desktop_height - dx*2) {
              height = desktop_height * 2 / 3;
            }
            if (left<desktop.left + dx || left>desktop.right - dx || top<desktop.top + dx || top>desktop.bottom - dx) {
              left = desktop.left + (desktop_width - width) / 2;
              top = desktop.top + (desktop_height - height) / 2;
            }
            std::cout << "set window rect(LTWH): " << left << "," << top << "," << width << "," << height << std::endl;
            SetWindowPos(
              GetHandle(), nullptr,
              left, top, width, height,
              SWP_NOZORDER | SWP_NOACTIVATE
            );
          }
          else {
            std::cout << "get desktop window failed, won't set window pos" << std::endl;
          }
          result->Success(nullptr);
        }
        
      }
      else {
        result->NotImplemented();
      }
    });

}
