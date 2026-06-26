import Flutter
import UIKit
import tealium

@objc(TealiumFirebasePlugin)
public class TealiumFirebasePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        TealiumPlugin.registerRemoteCommandFactory(FirebaseRemoteCommandFactory())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
}
