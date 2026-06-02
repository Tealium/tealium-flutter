import Flutter

@objc(TealiumAdobeVisitorPlugin)
public class TealiumAdobeVisitorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftTealiumAdobeVisitorPlugin.register(with: registrar)
    }
}
