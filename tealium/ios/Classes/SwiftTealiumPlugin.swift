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
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initialize" {
            initialize(call: call, result: result);
        } else if call.method == "track" {
            track(call: call)
        } else if call.method == "terminateInstance" {
            terminateInstance()
        } else if call.method == "addToDataLayer" {
            addToDataLayer(call: call)
        } else if call.method == "removeFromDataLayer" {
            removeFromDataLayer(call: call)
        } else if call.method == "deleteFromDataLayer" {
            removeFromDataLayer(call: call)
        } else if call.method == "getFromDataLayer" {
            getFromDataLayer(call: call, result: result)
        } else if call.method == "addRemoteCommand" {
            addRemoteCommand(call: call, result: result)
        } else if call.method == "removeRemoteCommand" {
            removeRemoteCommand(call: call)
        } else if call.method == "setConsentStatus" {
            setConsentStatus(call: call)
        } else if call.method == "getConsentStatus" {
            getConsentStatus(result: result)
        } else if call.method == "setConsentCategories" {
            setConsentCategories(call: call)
        } else if call.method == "getConsentCategories" {
            getConsentCategories(result: result)
        } else if call.method == "joinTrace" {
            joinTrace(call: call)
        } else if call.method == "leaveTrace" {
            leaveTrace()
        } else if call.method == "getVisitorId" {
            getVisitorId(result: result)
        } else if call.method == "setConsentExpiryListener" {
            setConsentExpiryListener()
        } else if call.method == "gatherTrackData" {
            gatherTrackData(call: call, result: result)
        } else if call.method == "resetVisitorId" {
            resetVisitorId()
        } else if call.method == "clearStoredVisitorIds" {
            clearStoredVisitorIds()
        }
    }
    
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let localConfig = tealiumConfig(from: arguments) else {
            return result(false)
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
    
    func track(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let track = dispatchFrom(arguments) else {
            return
        }
        tealium?.track(track)
    }
    
    func terminateInstance() {
        guard let config = self.config else {
            return
        }
        TealiumInstanceManager.shared.removeInstance(config: config)
        tealiumInstance = nil
    }
    
    func addToDataLayer(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let data = arguments["data"] as? [String: Any],
              let expiry = arguments["expiry"] as? String else {
            return
        }
        tealium?.dataLayer.add(data: data, expiry: expiryFrom(expiry))
    }
    
    func removeFromDataLayer(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let keys = arguments["keys"] as? [String] else {
            return
        }
        tealium?.dataLayer.delete(for: keys)
    }
    
    func getFromDataLayer(call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let key = arguments["key"] as? String,
              let value = tealium?.dataLayer.all[key] else {
            return
        }
        result(value)
    }
    
    func deleteFromDataLayer(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let key = arguments["key"] as? String else {
            return
        }
        tealium?.dataLayer.delete(for: key)
    }
    
    func addRemoteCommand(call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let id = arguments["id"] as? String else {
            return
        }
        let path = arguments["path"] as? String
        let url = arguments["url"] as? String
        let remoteCommand = remoteCommandFor(id, path: path, url: url)
        tealium?.remoteCommands?.add(remoteCommand)
    }
    
    func removeRemoteCommand(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let id = arguments["id"] as? String else {
            return
        }
        tealium?.remoteCommands?.remove(commandWithId: id)
    }
    
    func setConsentStatus(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let status = arguments["status"] as? String else {
            return
        }
        if status == TealiumFlutterConstants.consented {
            tealium?.consentManager?.userConsentStatus = .consented
        } else {
            tealium?.consentManager?.userConsentStatus = .notConsented
        }
    }
    
    func getConsentStatus(result: FlutterResult) {
        result(tealium?.consentManager?.userConsentStatus.rawValue ?? "unknown")
    }
    
    func setConsentCategories(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let categories = arguments["categories"] as? [String] else {
            return
        }
        tealium?.consentManager?.userConsentCategories = TealiumConsentCategories.consentCategoriesStringArrayToEnum(categories)
    }
    
    func getConsentCategories(result: FlutterResult) {
        var converted = [String]()
        tealium?.consentManager?.userConsentCategories?.forEach {
            converted.append($0.rawValue)
        }
        result(converted)
    }
    
    func joinTrace(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let id = arguments["id"] as? String else {
            return
        }
        tealium?.joinTrace(id: id)
    }
    
    func leaveTrace() {
        tealium?.leaveTrace()
    }
    
    func getVisitorId(result: FlutterResult) {
        result(tealium?.visitorId ?? "")
    }
    
    
    func resetVisitorId() {
        tealium?.resetVisitorId()
    }
    
    func clearStoredVisitorIds() {
        tealium?.clearStoredVisitorIds()
    }
    
    func setConsentExpiryListener() {
        tealium?.consentManager?.onConsentExpiraiton = {
            Self.invokeOnMain("callListener",
                              arguments: [Events.emitterName.rawValue: Events.consent.rawValue])
        }
    }
    
    func gatherTrackData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let retrieveCachedData = arguments["retrieveCachedData"] as? Bool else {
            tealium?.gatherTrackData(completion: { data in
                result(data)
            })
            return
        }
        tealium?.gatherTrackData(retrieveCachedData: retrieveCachedData, completion: { data in
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
