import UIKit
import Flutter
import GoogleMaps// Import GoogleMaps
import FirebaseCore
import restart

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // --------------------------------------------------
    RestartPlugin.generatedPluginRegistrantRegisterCallback = { [weak self] in
        GeneratedPluginRegistrant.register(with: self!)
    }
    // --------------------------------------------------

    GMSServices.provideAPIKey("AIzaSyAlwxsIsmaDI6I1kWsCNCt3C1NryGXu-do")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
