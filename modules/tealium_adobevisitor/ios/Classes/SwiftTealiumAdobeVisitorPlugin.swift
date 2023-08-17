import Flutter
import UIKit
import TealiumSwift
import tealium
import TealiumAdobeVisitorAPI

public class SwiftTealiumAdobeVisitorPlugin: NSObject, FlutterPlugin, OptionalModule {
    
    private var adobeVisitorOrgId: String? = nil
    private var adobeVisitorExistingEcid: String? = nil
    private var adobeVisitorRetries: Int? = nil
    private var adobeVisitorAuthState: Int? = nil
    private var adobeVisitorDataProviderId: String? = nil
    private var adobeVisitorCustomVisitorId: String? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tealium_adobevisitor", binaryMessenger: registrar.messenger())
        let instance = SwiftTealiumAdobeVisitorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        SwiftTealiumPlugin.registerOptionalModule(instance)
    }
    
    private var adobeModule: Tealium.AdobeVisitorWrapper? {
        get {
            SwiftTealiumPlugin.instance?
                .tealium?
                .adobeVisitorApi
        }
    }
    
    public func configure(config: TealiumConfig) {
        config.collectors?.append(Collectors.AdobeVisitor)
        
        if let adobeVisitorOrgId = adobeVisitorOrgId {
            config.adobeVisitorOrgId = adobeVisitorOrgId
        }
        if let adobeVisitorExistingEcid = adobeVisitorExistingEcid {
            config.adobeVisitorExistingEcid = adobeVisitorExistingEcid
        }
        if let adobeVisitorRetries = adobeVisitorRetries {
            config.adobeVisitorRetries = adobeVisitorRetries
        }
        if let adobeVisitorAuthState = adobeVisitorAuthState,
           let adobeVisitorAuthState = AdobeVisitorAuthState(rawValue: adobeVisitorAuthState) {
            config.adobeVisitorAuthState = adobeVisitorAuthState
        }
        if let adobeVisitorDataProviderId = adobeVisitorDataProviderId {
            config.adobeVisitorDataProviderId = adobeVisitorDataProviderId
        }
        if let adobeVisitorCustomVisitorId = adobeVisitorCustomVisitorId {
            config.adobeVisitorCustomVisitorId = adobeVisitorCustomVisitorId
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "configure" {
            configure(call, result: result);
        } else if call.method == "linkEcidToKnownIdentifier" {
            linkExistingEcidToKnownIdentifier(call, result: result)
        } else if call.method == "getAdobeVisitor" {
            getAdobeVisitor(result)
        } else if call.method == "resetVisitor" {
            resetVisitor()
        } else if call.method == "decorateUrl" {
            decorateUrl(call, result: result)
        } else if call.method == "getUrlParameters" {
          getUrlParameters(call, result: result)
        } else {
            result(false)
        }
    }
    
    func configure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            return result(false)
        }
        
        if let adobeVisitorOrgId = arguments["adobeVisitorOrgId"] as? String {
            self.adobeVisitorOrgId = adobeVisitorOrgId
        }
        if let adobeVisitorExistingEcid = arguments["adobeVisitorExistingEcid"] as? String {
            self.adobeVisitorExistingEcid = adobeVisitorExistingEcid
        }
        if let adobeVisitorRetries = arguments["adobeVisitorRetries"] as? Int {
            self.adobeVisitorRetries = adobeVisitorRetries
        }
        if let adobeVisitorAuthState = arguments["adobeVisitorAuthState"] as? Int {
            self.adobeVisitorAuthState = adobeVisitorAuthState
        }
        if let adobeVisitorDataProviderId = arguments["adobeVisitorDataProviderId"] as? String {
            self.adobeVisitorDataProviderId = adobeVisitorDataProviderId
        }
        if let adobeVisitorCustomVisitorId = arguments["adobeVisitorCustomVisitorId"] as? String {
            self.adobeVisitorCustomVisitorId = adobeVisitorCustomVisitorId
        }
    }
    
    func getAdobeVisitor(_ result: @escaping FlutterResult) {
        result(adobeModule?.visitor?.asDictionary())
    }
    
    func linkExistingEcidToKnownIdentifier(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let module = adobeModule,
              let arguments = call.arguments as? [String: Any],
              let knownId = arguments["knownId"] as? String,
              let adobeDataProviderId = arguments["adobeDataProviderId"] as? String else {
            return result(nil)
        }
        
        let completion: AdobeVisitorCompletion = { adobeResult in
            do {
                let visitor = try adobeResult.get()
                result(visitor.asDictionary())
            } catch {
                result(nil)
            }
        }
        
        if let adobeAuthState = arguments["authState"] as? Int,
           let adobeAuthState = AdobeVisitorAuthState(rawValue: adobeAuthState) {
            module.linkECIDToKnownIdentifier(knownId, adobeDataProviderId: adobeDataProviderId, authState: adobeAuthState, completion: completion)
        } else {
            module.linkECIDToKnownIdentifier(knownId, adobeDataProviderId: adobeDataProviderId, completion: completion)
        }
    }
    
    func resetVisitor() {
        adobeModule?.resetVisitor()
    }
    
    func decorateUrl(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let module = adobeModule,
              let arguments = call.arguments as? [String: Any],
              let url = arguments["url"] as? String,
              let url = URL(string: url) else {
            return result(nil)
        }
        
        module.decorateUrl(url, completion: { url in
            result(url.absoluteString)
        })
    }

    func getUrlParameters(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let module = adobeModule else {
            return result(nil)
        }

        module.getURLParameters(completion: { parameters in
            guard let parameters = parameters else {
                result(FlutterError(code: "Adobe Visitor", message: "Adobe Visitor was null. Check for valid Adobe Org ID.", details: nil))
                return
            }
            result([parameters.name:  parameters.value])
        })
    }

}
