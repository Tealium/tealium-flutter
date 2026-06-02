import Flutter

@objc(TealiumFirebasePlugin)
public class TealiumFirebasePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftTealiumFirebasePlugin.register(with: registrar)
    }
}
