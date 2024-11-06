import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "com.example.eventorchestr8/secure_screen"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let secureScreenChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        secureScreenChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method { 
              case "enableSecureScreen": 
                NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: OperationQueue.main) { _ in 
                  if UIScreen.main.isCaptured { 
                    let alertController = UIAlertController(title: "Warning", message: "Screenshots are not allowed.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        controller.present(alertController, animated: true)
                  } 
                } 
                result.success(nil) 
              case "disableSecureScreen": 
                NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil) 
                result.success(nil) 
              default: result.notImplemented() 
            }
        }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

