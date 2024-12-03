import Flutter
import UIKit
import tealium
import TealiumSwift

public class TealiumMomentsApiPlugin: NSObject, FlutterPlugin, OptionalModule{
    
    static func moduleName() -> String! {
        return "TealiumReactMomentsApi"
    }
    
    private var momentsApiRegion: String? = nil
    private var momentsApiReferrer: String? = nil
    
    private let KEY_MOMENTS_API_REGION = "momentsApiRegion"
    private let KEY_MOMENTS_API_REFERRER = "momentsApiReferrer"
    private let KEY_MOMENTS_API_ENGINE_ID = "engineId"
    
    // Tealium Configure
    public func configure(config: TealiumSwift.TealiumConfig) {
        config.collectors?.append(Collectors.MomentsAPI)
        
        if let region = momentsApiRegion {
            config.momentsAPIRegion = .regionFrom(region: region)
        }
        
        config.momentsAPIReferrer = momentsApiReferrer
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tealium_moments_api", binaryMessenger: registrar.messenger())
        let instance = TealiumMomentsApiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        SwiftTealiumPlugin.registerOptionalModule(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            configure(call, result: result)
        case "fetchEngineResponse":
            fetchEngineResponse(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MomentsApi Configure
    private func configure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            return result(FlutterError(code: "ConfigurationError",
                                       message: "Failed to configure MomentsApi",
                                       details: nil))
        }
        
        if let region = arguments[KEY_MOMENTS_API_REGION] as? String {
            setMomentsRegion(region: region)
        }
        
        let referrer = arguments[KEY_MOMENTS_API_REFERRER] as? String
        setMomentsReferrer(referrer: referrer)
        
        print("Moments config updated successfully.")
    }
    
    // Fetch Engine Response
    private func fetchEngineResponse(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let engineIdArg = call.arguments as? [String: Any],
                let engineId = engineIdArg[KEY_MOMENTS_API_ENGINE_ID] as? String else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Invalid or missing engineId. Must be a non-null String.",
                                details: nil))
            return
        }
        
        if let momentsInstance = SwiftTealiumPlugin.instance?.tealium?.momentsAPI {
            momentsInstance.fetchEngineResponse(engineID: engineId as String, completion: { engineResponse in
                switch engineResponse {
                case .success(let response):
                    result(response.asDictionary())
                case .failure(let error):
                    result("Failed to fetch engine response with error code: \(error.localizedDescription)")
                }
            })
        }
        else {
            result("Failed to fetch engine response as a Tealuim instance is not currently initialised")
        }
    }
    
    func setMomentsRegion(region: String) {
        momentsApiRegion = region
    }
    
    func setMomentsReferrer(referrer: String?) {
        momentsApiReferrer = referrer
    }
}
