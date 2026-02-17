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
    private func requireTealium() throws(FlutterError) -> Tealium {
        guard let tealium = tealium else {
            throw TealiumError.notInitialized
        }
        return tealium
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
        switch call.method {
        case "initialize":
            try initialize(call: call, result: result)
        case "terminateInstance":
            try terminateInstance(result: result)
        case "track":
            try track(call: call, result: result)
        case "addToDataLayer":
            try addToDataLayer(call: call, result: result)
        case "removeFromDataLayer", "deleteFromDataLayer":
            try removeFromDataLayer(call: call, result: result)
        case "getFromDataLayer":
            try getFromDataLayer(call: call, result: result)
        case "addRemoteCommand":
            try addRemoteCommand(call: call, result: result)
        case "removeRemoteCommand":
            try removeRemoteCommand(call: call, result: result)
        case "setConsentStatus":
            try setConsentStatus(call: call, result: result)
        case "getConsentStatus":
            try getConsentStatus(result: result)
        case "setConsentCategories":
            try setConsentCategories(call: call, result: result)
        case "getConsentCategories":
            try getConsentCategories(result: result)
        case "joinTrace":
            try joinTrace(call: call, result: result)
        case "leaveTrace":
            try leaveTrace(result: result)
        case "getVisitorId":
            try getVisitorId(result: result)
        case "setConsentExpiryListener":
            try setConsentExpiryListener(result: result)
        case "gatherTrackData":
            try gatherTrackData(call: call, result: result)
        case "resetVisitorId":
            try resetVisitorId(result: result)
        case "clearStoredVisitorIds":
            try clearStoredVisitorIds(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
        } catch {
            result(error)
        }
    }
    
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let localConfig = tealiumConfig(from: call, result: result) else {
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
    
    func track(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let track = dispatchFrom(call, result: result) else {
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
    
    func addToDataLayer(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let arguments = call.arguments as? [String: Any] else {
            result(TealiumError.missingParameter("Arguments"))
            return
        }
        guard let data: [String: Any] = call.requireParameter("data", result: result),
              let expiry: String = call.requireParameter("expiry", result: result) else {
            return
        }
        tealium.dataLayer.add(data: data, expiry: expiryFrom(expiry))
        result(nil)
    }
    
    func removeFromDataLayer(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let keys: [String] = call.requireParameter("keys", result: result) else { 
            return
        }

        tealium.dataLayer.delete(for: keys)
        result(nil)
    }
    
    func getFromDataLayer(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let key: String = call.requireParameter("key", result: result) else { 
            return
        }
        
        let value = tealium.dataLayer.all[key]
        result(value)
    }
    
    func deleteFromDataLayer(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let key: String = call.requireParameter("key", result: result) else { 
            return
        }
        tealium.dataLayer.delete(for: key)
        result(nil)
    }
    
    func addRemoteCommand(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let id: String = call.requireParameter("id", result: result) else { 
            return
        }

        guard let arguments = call.arguments as? [String: Any] else {
            return
        }

        let path = arguments["path"] as? String
        let url = arguments["url"] as? String
        let remoteCommand = remoteCommandFor(id, path: path, url: url)
        tealium.remoteCommands?.add(remoteCommand)
        result(nil)
    }
    
    func removeRemoteCommand(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let id: String = call.requireParameter("id", result: result) else { 
            return
        }
        tealium.remoteCommands?.remove(commandWithId: id)
        result(nil)
    }
    
    func setConsentStatus(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let status: String = call.requireParameter("status", result: result) else { 
            return
        }
        if status == TealiumFlutterConstants.consented {
            tealium.consentManager?.userConsentStatus = .consented
        } else {
            tealium.consentManager?.userConsentStatus = .notConsented
        }
        result(nil)
    }
    
    func getConsentStatus(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        result(tealium.consentManager?.userConsentStatus.rawValue ?? "unknown")
    }
    
    func setConsentCategories(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let categories: [String] = call.requireParameter("categories", result: result) else { 
            return
        }
        tealium.consentManager?.userConsentCategories = TealiumConsentCategories.consentCategoriesStringArrayToEnum(categories)
        result(nil)
    }
    
    func getConsentCategories(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        var converted = [String]()
        tealium.consentManager?.userConsentCategories?.forEach {
            converted.append($0.rawValue)
        }
        result(converted)
    }
    
    func joinTrace(call: FlutterMethodCall, result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        guard let id: String = call.requireParameter("id", result: result) else { 
            return
        }
        tealium.joinTrace(id: id)
        result(nil)
    }
    
    func leaveTrace(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        tealium.leaveTrace()
        result(nil)
    }
    
    func getVisitorId(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        result(tealium.visitorId)
    }
    
    func resetVisitorId(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        tealium.resetVisitorId()
        result(nil)
    }
    
    func clearStoredVisitorIds(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        tealium.clearStoredVisitorIds()
        result(nil)
    }
    
    func setConsentExpiryListener(result: FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        tealium.consentManager?.onConsentExpiraiton = {
            Self.invokeOnMain("callListener",
                              arguments: [Events.emitterName.rawValue: Events.consent.rawValue])
        }
        result(nil)
    }
    
    func gatherTrackData(call: FlutterMethodCall, result: @escaping FlutterResult) throws(FlutterError) -> Void {
        let tealium = try requireTealium()
        
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
