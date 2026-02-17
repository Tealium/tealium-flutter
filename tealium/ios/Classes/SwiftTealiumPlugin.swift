import Flutter
import UIKit
import TealiumSwift

public class SwiftTealiumPlugin: NSObject, FlutterPlugin {
    private typealias Events = TealiumFlutterConstants.Events
    var tealiumInstance: Tealium?
    private var config: TealiumConfig?
    var visitorServiceDelegate: VisitorServiceDelegate = VisitorDelegate()
    var consentExpiryCallback: (() -> Void)?
    static private var channel: FlutterMethodChannel?
    static var remoteCommandFactories = [String: RemoteCommandFactory]()
    static var optionalModules = [OptionalModule]()
    static var pluginInstance: SwiftTealiumPlugin? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "tealium", binaryMessenger: registrar.messenger())
        pluginInstance = SwiftTealiumPlugin()
        guard let channel = channel else {
            return
        }
        if let instance = pluginInstance {
            registrar.addMethodCallDelegate(instance, channel: channel)
        }
    }
    
    public static func registerRemoteCommandFactory(_ factory: RemoteCommandFactory) {
        remoteCommandFactories[factory.name] = factory
    }
    
    public static func registerOptionalModule(_ module: OptionalModule) {
        optionalModules.append(module)
    }

    public static var instance: SwiftTealiumPlugin? {
        get {
            pluginInstance
        }
    }

    public var tealium: Tealium? {
        get {
            tealiumInstance
        }
    }
    
    /// Helper to get Tealium instance or send error if not initialized.
    /// Returns nil if Tealium is not initialized (error is sent to result).
    private func requireTealium(_ result: FlutterResult) -> Tealium? {
        guard let tealium = tealium else {
            result(TealiumError.notInitialized)
            return nil
        }
        return tealium
    }
    
    /// Helper to get a required parameter or send error if nil.
    /// Returns the value if non-nil, otherwise sends missing parameter error to result and returns nil.
    private func requireParameter<T>(_ value: T?, result: FlutterResult, paramName: String) -> T? {
        guard let value = value else {
            result(TealiumError.missingParameter(paramName))
            return nil
        }
        return value
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(call: call, result: result)
        case "terminateInstance":
            terminateInstance(result: result)
        case "track":
            track(call: call, result: result)
        case "addToDataLayer":
            addToDataLayer(call: call, result: result)
        case "removeFromDataLayer", "deleteFromDataLayer":
            removeFromDataLayer(call: call, result: result)
        case "getFromDataLayer":
            getFromDataLayer(call: call, result: result)
        case "addRemoteCommand":
            addRemoteCommand(call: call, result: result)
        case "removeRemoteCommand":
            removeRemoteCommand(call: call, result: result)
        case "setConsentStatus":
            setConsentStatus(call: call, result: result)
        case "getConsentStatus":
            getConsentStatus(result: result)
        case "setConsentCategories":
            setConsentCategories(call: call, result: result)
        case "getConsentCategories":
            getConsentCategories(result: result)
        case "joinTrace":
            joinTrace(call: call, result: result)
        case "leaveTrace":
            leaveTrace(result: result)
        case "getVisitorId":
            getVisitorId(result: result)
        case "setConsentExpiryListener":
            setConsentExpiryListener(result: result)
        case "gatherTrackData":
            gatherTrackData(call: call, result: result)
        case "resetVisitorId":
            resetVisitorId(result: result)
        case "clearStoredVisitorIds":
            clearStoredVisitorIds(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let localConfig = requireParameter(tealiumConfig(from: arguments), result: result, paramName: "Configuration") else {
            return
        }
        self.config = localConfig.copy
        
        SwiftTealiumPlugin.optionalModules.forEach { module in
            module.configure(config: localConfig)
        }
        
        tealiumInstance = Tealium(config: localConfig) { _ in
            
            self.tealium?.onVisitorId?.subscribe { visitorId in
                Self.invokeOnMain("callListener",
                                  arguments: [
                                    Events.emitterName.rawValue: Events.visitorId.rawValue,
                                    "visitorId": visitorId
                                  ])
            }
            result(true)
        }
    }
    
    func track(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let track = requireParameter(dispatchFrom(arguments), result: result, paramName: "Track dispatch data") else {
            return
        }
        tealium.track(track)
        result(nil)
    }
    
    func terminateInstance(result: FlutterResult) {
        guard let config = self.config else {
            result(nil)
            return
        }
        TealiumInstanceManager.shared.removeInstance(config: config)
        tealiumInstance = nil
        result(nil)
    }
    
    func addToDataLayer(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any] else {
            result(TealiumError.missingParameter("Arguments"))
            return
        }
        guard let data = requireParameter(arguments["data"] as? [String: Any], result: result, paramName: "Data"),
              let expiry = requireParameter(arguments["expiry"] as? String, result: result, paramName: "Expiry") else {
            return
        }
        tealium.dataLayer.add(data: data, expiry: expiryFrom(expiry))
        result(nil)
    }
    
    func removeFromDataLayer(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let keys = requireParameter(arguments["keys"] as? [String], result: result, paramName: "Keys") else {
            return
        }
        tealium.dataLayer.delete(for: keys)
        result(nil)
    }
    
    func getFromDataLayer(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let key = requireParameter(arguments["key"] as? String, result: result, paramName: "Key") else {
            return
        }
        
        let value = tealium.dataLayer.all[key]
        result(value)
    }
    
    func deleteFromDataLayer(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let key = requireParameter(arguments["key"] as? String, result: result, paramName: "Key") else {
            return
        }
        tealium.dataLayer.delete(for: key)
        result(nil)
    }
    
    func addRemoteCommand(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let id = requireParameter(arguments["id"] as? String, result: result, paramName: "ID") else {
            return
        }
        let path = arguments["path"] as? String
        let url = arguments["url"] as? String
        let remoteCommand = remoteCommandFor(id, path: path, url: url)
        tealium.remoteCommands?.add(remoteCommand)
        result(nil)
    }
    
    func removeRemoteCommand(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let id = requireParameter(arguments["id"] as? String, result: result, paramName: "ID") else {
            return
        }
        tealium.remoteCommands?.remove(commandWithId: id)
        result(nil)
    }
    
    func setConsentStatus(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let status = requireParameter(arguments["status"] as? String, result: result, paramName: "Status") else {
            return
        }
        if status == TealiumFlutterConstants.consented {
            tealium.consentManager?.userConsentStatus = .consented
        } else {
            tealium.consentManager?.userConsentStatus = .notConsented
        }
        result(nil)
    }
    
    func getConsentStatus(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        result(tealium.consentManager?.userConsentStatus.rawValue ?? "unknown")
    }
    
    func setConsentCategories(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let categories = requireParameter(arguments["categories"] as? [String], result: result, paramName: "Categories") else {
            return
        }
        tealium.consentManager?.userConsentCategories = TealiumConsentCategories.consentCategoriesStringArrayToEnum(categories)
        result(nil)
    }
    
    func getConsentCategories(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        var converted = [String]()
        tealium.consentManager?.userConsentCategories?.forEach {
            converted.append($0.rawValue)
        }
        result(converted)
    }
    
    func joinTrace(call: FlutterMethodCall, result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        guard let arguments = call.arguments as? [String: Any],
              let id = requireParameter(arguments["id"] as? String, result: result, paramName: "Trace ID") else {
            return
        }
        tealium.joinTrace(id: id)
        result(nil)
    }
    
    func leaveTrace(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        tealium.leaveTrace()
        result(nil)
    }
    
    func getVisitorId(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        result(tealium.visitorId)
    }
    
    func resetVisitorId(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        tealium.resetVisitorId()
        result(nil)
    }
    
    func clearStoredVisitorIds(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        tealium.clearStoredVisitorIds()
        result(nil)
    }
    
    func setConsentExpiryListener(result: FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        tealium.consentManager?.onConsentExpiraiton = {
            Self.invokeOnMain("callListener",
                              arguments: [Events.emitterName.rawValue: Events.consent.rawValue])
        }
        result(nil)
    }
    
    func gatherTrackData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let tealium = requireTealium(result) else { return }
        
        guard let arguments = call.arguments as? [String: Any],
              let retrieveCachedData = arguments["retrieveCachedData"] as? Bool else {
            tealium.gatherTrackData(completion: { data in
                result(data)
            })
            return
        }
        tealium.gatherTrackData(retrieveCachedData: retrieveCachedData, completion: { data in
            result(data)
        })
    }

    static func invokeOnMain(_ method: String, arguments: [String: Any]) {
        TealiumQueues.secureMainThreadExecution {
            SwiftTealiumPlugin.channel?.invokeMethod(method,
                                                     arguments: arguments)
        }
    }
}
