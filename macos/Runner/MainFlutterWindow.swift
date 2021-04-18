import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    configMethodChannel()
    
    super.awakeFromNib()
  }
    
  func configMethodChannel() {
    let controller:FlutterViewController = self.contentViewController as! FlutterViewController;
    let channel = FlutterMethodChannel(
      name:"chaldea.narumi.cc/chaldea",
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch call.method {
          case "alwaysOnTop":
            let onTop: Bool? = (call.arguments as? [String: Any])?["onTop"] as? Bool
            if onTop == nil {
              print("[macos] set alwaysOnTop: nil")
              result(false)
            }else{
              print("[macos] set alwaysOnTop: \(onTop!)")
              self.level = onTop! ? NSWindow.Level.floating : NSWindow.Level.normal
              result(true);
            }
            break
          default:
            result(FlutterMethodNotImplemented)
      }
    })
  }
}
