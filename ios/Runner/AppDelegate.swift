import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   if #available(iOS 10.0, *) {
     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
   }
   GMSServices.provideAPIKey("AIzaSyB28B-Y6CorroYhjSF_7og-ZekyTmb2sKk")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
