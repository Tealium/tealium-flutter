import Flutter
import UIKit
import TealiumSwift

public class SwiftTealiumPlugin: NSObject, FlutterPlugin {

  var tealium: Tealium?
  private var config: TealiumConfig?
  var visitorServiceDelegate: VisitorServiceDelegate = VisitorDelegate()
  var consentExpiryCallback: (() -> Void)?
  static var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "tealium", binaryMessenger: registrar.messenger())
    let instance = SwiftTealiumPlugin()
    guard let channel = channel else {
        return
    }
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
      result("iOS " + UIDevice.current.systemVersion)
    } else if call.method == "initialize" {
      initialize(call: call, result: result);
    } else if call.method == "track" {
      track(call: call, result: result)
    } else if call.method == "terminateInstance" {
        terminateInstance(call: call, result: result)
    } else if call.method == "addToDataLayer" {
        addToDataLayer(call: call, result: result)
    } else if call.method == "removeFromDataLayer" {
        removeFromDataLayer(call: call, result: result)
    } else if call.method == "deleteFromDataLayer" {
        removeFromDataLayer(call: call, result: result)
    } else if call.method == "getFromDataLayer" {
        getFromDataLayer(call: call, result: result)
    } else if call.method == "addRemoteCommand" {
        addRemoteCommand(call: call, result: result)
    } else if call.method == "removeRemoteCommand" {
        removeRemoteCommand(call: call, result: result)
    } else if call.method == "setConsentStatus" {
        setConsentStatus(call: call, result: result)
    } else if call.method == "getConsentStatus" {
        getConsentStatus(call: call, result: result)
    } else if call.method == "setConsentCategories" {
        setConsentCategories(call: call, result: result)
    } else if call.method == "getConsentCategories" {
        getConsentCategories(call: call, result: result)
    } else if call.method == "joinTrace" {
        joinTrace(call: call, result: result)
    } else if call.method == "leaveTrace" {
        leaveTrace(call: call, result: result)
    } else if call.method == "getVisitorId" {
        getVisitorId(call: call, result: result)
    } else if call.method == "setConsentExpiryListener" {
        setConsentExpiryListener(call: call, result: result)
    }
  }

  func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
         let localConfig = tealiumConfig(from: arguments) else {
            return result(false)
        }
        self.config = localConfig.copy
        tealium = Tealium(config: localConfig) { _ in 
            result(true)
        }
  }

  func track(call: FlutterMethodCall, result: FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
    let track = dispatchFrom(arguments) else {
            return
        }
     tealium?.track(track)
  }

  func terminateInstance(call: FlutterMethodCall, result: FlutterResult) {
      guard let config = self.config else {
          return
      }
      TealiumInstanceManager.shared.removeInstance(config: config)
      tealium = nil
  }

  func addToDataLayer(call: FlutterMethodCall, result: FlutterResult) {
      guard let arguments = call.arguments as? [String: Any],
      let data = arguments["data"] as? [String: Any],
      let expiry = arguments["expiry"] as? String else {
          return
      }
      tealium?.dataLayer.add(data: data, expiry: expiryFrom(expiry))
  }

  func removeFromDataLayer(call: FlutterMethodCall, result: FlutterResult) {
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

  func deleteFromDataLayer(call: FlutterMethodCall, result: FlutterResult) {
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
        let remoteCommand = RemoteCommand(commandId: id, description: nil) { response in
             guard var payload = response.payload else {
                 return
             }
             payload[TealiumFlutterConstants.Events.emitterName.rawValue] = TealiumFlutterConstants.Events.remoteCommand.rawValue
             SwiftTealiumPlugin.channel?.invokeMethod("callListener", arguments: payload)
        }
        tealium?.remoteCommands?.add(remoteCommand)
    }

   func removeRemoteCommand(call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
        let id = arguments["id"] as? String else {
            return
        }
        tealium?.remoteCommands?.remove(commandWithId: id)
   }

  func setConsentStatus(call: FlutterMethodCall, result: FlutterResult) {
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

  func getConsentStatus(call: FlutterMethodCall, result: FlutterResult) {
      result(tealium?.consentManager?.userConsentStatus.rawValue ?? "unknown")
  }

  func setConsentCategories(call: FlutterMethodCall, result: FlutterResult) {
      guard let arguments = call.arguments as? [String: Any],
            let categories = arguments["categories"] as? [String] else {
           return
      }
    tealium?.consentManager?.userConsentCategories = TealiumConsentCategories.consentCategoriesStringArrayToEnum(categories)
  }

  func getConsentCategories(call: FlutterMethodCall, result: FlutterResult) {
    var converted = [String]()
    tealium?.consentManager?.userConsentCategories?.forEach {
        converted.append($0.rawValue)
    }
    result(converted)
  }

  func joinTrace(call: FlutterMethodCall, result: FlutterResult) {
      guard let arguments = call.arguments as? [String: Any],
       let id = arguments["id"] as? String else {
           return
      }
      tealium?.joinTrace(id: id)
  }

  func leaveTrace(call: FlutterMethodCall, result: FlutterResult) {
      tealium?.leaveTrace()
  }

  func getVisitorId(call: FlutterMethodCall, result: FlutterResult) {
      result(tealium?.visitorId ?? "")
  }

  func setConsentExpiryListener(call: FlutterMethodCall, result: FlutterResult) {
      tealium?.consentManager?.onConsentExpiraiton = {
          SwiftTealiumPlugin.channel?.invokeMethod("callListener",
           arguments: [TealiumFlutterConstants.Events.emitterName.rawValue: TealiumFlutterConstants.Events.consent.rawValue])
      }
  }

}
