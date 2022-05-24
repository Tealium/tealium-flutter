import TealiumSwift

public extension SwiftTealiumPlugin {
    
    func tealiumConfig(from dictionary: [String: Any]) -> TealiumConfig? {
        guard let account = dictionary[.account] as? String,
              let profile = dictionary[.profile] as? String,
              let environment = dictionary[.environment] as? String else {
            return nil
        }
        
        let localConfig = TealiumConfig(account: account,
                                        profile: profile,
                                        environment: environment,
                                        dataSource: dictionary[.dataSource] as? String)
        
        if let policyString = dictionary[.consentPolicy] as? String,
           let policy = consentPolicyFrom(policyString) {
            localConfig.consentPolicy = policy
            localConfig.consentLoggingEnabled =  dictionary[.consentLoggingEnabled] as? Bool ?? true
            localConfig.onConsentExpiration = {
                var payload = [String: String]()
                payload[TealiumFlutterConstants.Events.emitterName.rawValue] = TealiumFlutterConstants.Events.consent.rawValue
                SwiftTealiumPlugin.channel?.invokeMethod("callListener", arguments: payload)
            }
        }
        
        if let consentExpiry = dictionary[.consentExpiry] as? [String: Any],
            let time = consentExpiry[.time] as? Int,
            let unit = consentExpiry[.unit] as? String {
            var unitType = TimeUnit.days

            switch unit.lowercased() {
            case TealiumFlutterConstants.minutes:
                    unitType = .minutes
            case TealiumFlutterConstants.hours:
                    unitType = .hours
            case TealiumFlutterConstants.months:
                    unitType = .months
                default:
                    break
            }
            localConfig.consentExpiry = (time: time, unit: unitType)
        }
        
        if let customVisitorId = dictionary[.customVisitorId] as? String {
            localConfig.existingVisitorId = customVisitorId
        }
        
        var configDispatchers = [Dispatcher.Type]()
        var configCollectors = [Collector.Type]()
        
        if let dispatchers = dictionary[.dispatchers] as? [String] {
            if dispatchers.contains(TealiumFlutterConstants.tagManagement) {
                configDispatchers.append(Dispatchers.TagManagement)
            }
            
            if dispatchers.contains(TealiumFlutterConstants.collect) {
                configDispatchers.append(Dispatchers.Collect)
            }
            
            if dispatchers.contains(TealiumFlutterConstants.remoteCommands) {
                configDispatchers.append(Dispatchers.RemoteCommands)
                localConfig.remoteAPIEnabled = true
            }
        }
        
        if let collectors = dictionary[.collectors] as? [String] {
            if collectors.contains(TealiumFlutterConstants.appData) {
                configCollectors.append(Collectors.AppData)
            }
            
            if collectors.contains(TealiumFlutterConstants.connectivity) {
                configCollectors.append(Collectors.Connectivity)
            }
            
            if collectors.contains(TealiumFlutterConstants.deviceData) {
                configCollectors.append(Collectors.Device)
            }
            
            if collectors.contains(TealiumFlutterConstants.lifecycle) {
                configCollectors.append(Collectors.Lifecycle)
            }
        }
        
        if let useRemoteLibrarySettings = dictionary[.useRemoteLibrarySettings] as? Bool {
            localConfig.shouldUseRemotePublishSettings = useRemoteLibrarySettings
        }
        
        if let logLevel = dictionary[.logLevel] as? String {
            localConfig.logLevel = logLevelFrom(logLevel)
        }
        
        if let overrideCollectURL = dictionary[.overrideCollectURL] as? String {
            localConfig.overrideCollectURL = overrideCollectURL
        }
        
        if let overrideCollectProfile = dictionary[.overrideCollectProfile] as? String {
            localConfig.overrideCollectProfile = overrideCollectProfile
        }
        
        if let overrideTagManagementURL = dictionary[.overrideTagManagementURL] as? String {
            localConfig.tagManagementOverrideURL = overrideTagManagementURL
        }
        
        if let overrideCollectBatchURL = dictionary[.overrideCollectBatchURL] as? String {
            localConfig.overrideCollectBatchURL = overrideCollectBatchURL
        }
        
        if let overrideLibrarySettingsURL = dictionary[.overrideLibrarySettingsURL] as? String {
            localConfig.publishSettingsURL = overrideLibrarySettingsURL
        }
        
        localConfig.qrTraceEnabled = dictionary[.qrTraceEnabled] as? Bool ?? true
        localConfig.deepLinkTrackingEnabled = dictionary[.deepLinkTrackingEnabled] as? Bool ?? true
        localConfig.lifecycleAutoTrackingEnabled = dictionary[.lifecycleAutotrackingEnabled] as? Bool ?? true
        
        if dictionary[.visitorServiceEnabled] as? Bool == true {
            configCollectors.append(Collectors.VisitorService)
            localConfig.visitorServiceDelegate = visitorServiceDelegate
        }
        
        localConfig.memoryReportingEnabled = dictionary[.memoryReportingEnabled] as? Bool ?? true
        localConfig.collectors = configCollectors
        localConfig.dispatchers = configDispatchers
        
        return localConfig
    }
    
    func consentPolicyFrom(_ policy: String) -> TealiumConsentPolicy? {
        switch policy.lowercased() {
            case TealiumFlutterConstants.ccpa:
                return .ccpa
            case TealiumFlutterConstants.gdpr:
                return .gdpr
            default:
                return nil
        }
    }
    
    func expiryFrom(_ expiry: String) -> Expiry {
        switch expiry.lowercased() {
            case TealiumFlutterConstants.forever:
                return .forever
            case TealiumFlutterConstants.restart:
                return .untilRestart
            default:
                return .session
        }
    }
    
    func dispatchFrom(_ payload: [String: Any]) -> TealiumDispatch? {
        let type = payload[.type] as? String ?? TealiumFlutterConstants.event
        let dataLayer = payload[.dataLayer] as? [String: Any]
        switch type.lowercased() {
        case TealiumFlutterConstants.view:
            guard let viewName = payload[.viewName] as? String else {
                return nil
            }
            return TealiumView(viewName, dataLayer: dataLayer)
        default:
            guard let eventName = payload[.eventName] as? String else {
                return nil
            }
            return TealiumEvent(eventName, dataLayer: dataLayer)
        }
    }
    
    func logLevelFrom(_ logLevel: String) -> TealiumLogLevel {
        switch logLevel.lowercased() {
        case TealiumFlutterConstants.dev:
            return .info
        case TealiumFlutterConstants.qa:
            return .debug
        case TealiumFlutterConstants.prod:
            return .error
        case TealiumFlutterConstants.silent:
            return .silent
        default:
            return .error
        }
    }

}

extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript(key: TealiumFlutterConstants.Config) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
    subscript(key: TealiumFlutterConstants.Dispatch) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
}