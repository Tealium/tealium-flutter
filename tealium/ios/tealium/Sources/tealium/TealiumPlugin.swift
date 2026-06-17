import Flutter

@objc(TealiumPlugin)
public class TealiumPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftTealiumPlugin.register(with: registrar)
    }
}
