import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    initFlutterMethodChannel()
    super.awakeFromNib()
  }
    
  func initFlutterMethodChannel() {
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
            print("set always on top: \(onTop ??? "nil")")
            if onTop == true {
              self.level = NSWindow.Level.floating
            }else if onTop == false {
              self.level = NSWindow.Level.normal
            }
            result(onTop);
          default:
            result(FlutterMethodNotImplemented)
      }
    })
  }
}
