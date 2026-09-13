import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications
import alarm

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    // Restore with the alarm background modes and permitted task identifier in Info.plist.
    // SwiftAlarmPlugin.registerBackgroundTasks()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    let chaldeaChannel = FlutterMethodChannel(name: "chaldea.narumi.cc/chaldea",
                                              binaryMessenger: engineBridge.applicationRegistrar.messenger())
    chaldeaChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getCFNetworkVersion" {
        result(getCFNetworkVersion())
      } else {
        result(FlutterMethodNotImplemented)
        return
      }
    })

    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

func getCFNetworkVersion() -> String? {
  guard
    let bundle = Bundle(identifier: "com.apple.CFNetwork"),
    let versionAny = bundle.infoDictionary?[kCFBundleVersionKey as String],
    let version = versionAny as? String
  else { return nil }
  return version
}
