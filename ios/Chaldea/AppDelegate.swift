import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications
import alarm

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    SwiftAlarmPlugin.registerBackgroundTasks()

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let chaldeaChannel = FlutterMethodChannel(name: "chaldea.narumi.cc/chaldea",
                                              binaryMessenger: controller.binaryMessenger)
    chaldeaChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getCFNetworkVersion" {
        result(getCFNetworkVersion())
      } else {
        result(FlutterMethodNotImplemented)
        return
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
