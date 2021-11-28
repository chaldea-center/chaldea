import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TODO: temporary solution to enable 120Hz ProMotion
    if #available(iOS 15.0, *) {
      let displayLink = CADisplayLink(target: self, selector: #selector(step))
      displayLink.preferredFrameRateRange = CAFrameRateRange(minimum:80, maximum:120, preferred:120)
      displayLink.add(to: .current, forMode: .default)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc func step(displaylink: CADisplayLink) {
      // Will be called once a frame has been built while matching desired frame rate
    }
}
