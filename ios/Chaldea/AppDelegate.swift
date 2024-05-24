import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
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
