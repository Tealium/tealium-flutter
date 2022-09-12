import Flutter
import UIKit
import tealium

public class SwiftTealiumFirebasePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      SwiftTealiumPlugin.registerRemoteCommandFactory(FirebaseRemoteCommandFactory())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      result(FlutterMethodNotImplemented)
  }
}
