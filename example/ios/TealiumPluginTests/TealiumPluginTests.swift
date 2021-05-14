//
//  TealiumPluginTests.swift
//  TealiumPluginTests
//
//  Created by Christina Schell on 4/12/21.
//

import XCTest
import TealiumSwift
import tealium

class TealiumPluginTests: XCTestCase {
    
    var tealiumPlugin: SwiftTealiumPlugin?

    override func setUpWithError() throws {
        tealiumPlugin = SwiftTealiumPlugin()
    }

    func testInitializeSucceeds_WithBasicConfig() throws {
        let call = FlutterMethodCall( methodName: "initialize", arguments: TestData.basicConfig )
        tealiumPlugin!.handle( call, result: { result in
            guard let result = result as? Bool else {
                return XCTFail("Invalid Result")
            }
            XCTAssertTrue(result)
        })
    }
    
    func testInitializeFails_WithInvalidConfig() throws {
        let call = FlutterMethodCall( methodName: "initialize", arguments: TestData.invalidConfig )
        tealiumPlugin!.handle( call, result: { result in
            guard let result = result as? Bool else {
                return XCTFail("Invalid Result")
            }
            XCTAssertFalse(result)
        })
    }
    
    func testTealiumConfigFrom_ReturnsNil_WhenNoAccountProfileEnvironment() {
        
        var config = ["account": "testAccount"]
        
        var result = tealiumPlugin!.tealiumConfig(from: config)
        
        XCTAssertNil(result)
        
        config = ["account": "testAccount", "profile": "testProfile"]
        
        result = tealiumPlugin!.tealiumConfig(from: config)
        
        XCTAssertNil(result)
    }
    
    func testTealiumConfigFrom_Succeeds_WithExpectedOutput() {
        let result = tealiumPlugin!.tealiumConfig(from: TestData.fullConfig)!
        let collectors = result.collectors.map { $0.description }
        let dispatchers = result.dispatchers.map { $0.description }
        
        XCTAssertEqual(result.consentPolicy, .gdpr)
        XCTAssertFalse(result.consentLoggingEnabled)
        XCTAssertEqual(result.consentExpiry?.time, 30)
        XCTAssertEqual(result.consentExpiry?.unit, .days)
        XCTAssertEqual(result.existingVisitorId, "someCustomVisitorId")
        XCTAssertEqual(collectors, "[TealiumSwift.AppDataModule, TealiumSwift.ConnectivityModule, TealiumSwift.DeviceDataModule, TealiumSwift.LifecycleModule, TealiumSwift.VisitorServiceModule]")
        XCTAssertEqual(dispatchers, "[TealiumSwift.TagManagementModule, TealiumSwift.CollectModule, TealiumSwift.RemoteCommandsModule]")
        XCTAssertFalse(result.shouldUseRemotePublishSettings)
        XCTAssertFalse(result.qrTraceEnabled)
        XCTAssertFalse(result.deepLinkTrackingEnabled)
        XCTAssertFalse(result.lifecycleAutoTrackingEnabled)
        XCTAssertFalse(result.memoryReportingEnabled)
        XCTAssertEqual(result.logLevel, .info)
        XCTAssertEqual(result.overrideCollectURL, "https://override.collect.url")
        XCTAssertEqual(result.overrideCollectBatchURL, "https://override.batch.url")
        XCTAssertEqual(result.tagManagementOverrideURL, "https://override.tm.url")
        XCTAssertEqual(result.publishSettingsURL, "https://override.libsettings.url")
    }
    
    func testConsentPolicyFrom_ReturnsNil() {
        let result = tealiumPlugin!.consentPolicyFrom("invalidValue")
        
        XCTAssertNil(result)
    }
    
    func testExpiryFrom_ReturnsExpectedValues() {
        let expiries = ["phoeva", "forever", "untilRestart", "session"]
        let expected = ["session", "forever", "untilRestart", "session"]
        
        expiries.enumerated().forEach {
            let result = tealiumPlugin!.expiryFrom($0.element)
            XCTAssertEqual(result.description, expected[$0.offset])
        }
    }
    
    func testDispatchFrom_ReturnsTealiumEvent_WhenNoTypeProvided() {
        let dispatch: [String: Any] = ["eventName": "someEvent", "dataLayer": ["foo": "bar"]]
        
        guard let _ = tealiumPlugin!.dispatchFrom(dispatch) as? TealiumEvent else {
            return XCTFail("Wrong return type, should be TealiumEvent")
        }
    }
    
    func testDispatchFrom_ReturnsTealiumView() {
        let dispatch: [String: Any] = ["type": "view", "viewName": "someView", "dataLayer": ["foo": "bar"]]
        
        guard let _ = tealiumPlugin!.dispatchFrom(dispatch) as? TealiumView else {
            return XCTFail("Wrong return type, should be TealiumEvent")
        }
    }
    
    func testDispatchFrom_ReturnsNil_WhenNoEventName() {
        let dispatch = ["type": "event"]
        
        XCTAssertNil(tealiumPlugin!.dispatchFrom(dispatch))
    }
    
    func testDispatchFrom_ReturnsNil_WhenNoViewName() {
        let dispatch = ["type": "view"]
        
        XCTAssertNil(tealiumPlugin!.dispatchFrom(dispatch))
    }
    
    func testLogLevelFrom_ReturnsExpectedValues() {
        let logLevels = ["loggie", "dev", "qa", "prod", "silent"]
        let expected = ["error", "info", "debug", "error", "silent"]
        
        logLevels.enumerated().forEach {
            let result = tealiumPlugin!.logLevelFrom($0.element)
            XCTAssertEqual(result.description.lowercased(), expected[$0.offset])
        }
    }

}

fileprivate struct TestData {
    
    static var invalidConfig: [String: Any] { ["account": "testAccount", "profile": "testProfile"] }
    
    static var basicConfig: [String: Any] {
        ["account": "testAccount", "profile": "testProfile", "environment": "testEnvironment", "collectors": ["AppData", "Connectivity", "Device", "Lifecycle"], "dispatchers": ["Collect"]]
    }
    
    static var fullConfig: [String: Any] {
        ["account": "testAccount", "profile": "testProfile", "environment": "testEnvironment", "dataSource": "abc123", "collectors": ["AppData", "Connectivity", "DeviceData", "Lifecycle"], "dispatchers": ["Collect", "TagManagement", "RemoteCommands"], "consentPolicy": "gdpr", "consentLoggingEnabled": false, "consentExpiry": ["time": 30, "unit": "days"], "customVisitorId": "someCustomVisitorId", "lifecycleAutotrackingEnabled": false, "useRemoteLibrarySettings": false, "logLevel": "dev", "overrideCollectURL": "https://override.collect.url", "overrideTagManagementURL": "https://override.tm.url", "overrideCollectBatchURL": "https://override.batch.url", "overrideLibrarySettingsURL": "https://override.libsettings.url", "qrTraceEnabled": false, "deepLinkTrackingEnabled": false, "memoryReportingEnabled": false, "visitorServiceEnabled": true]
    }
    
}

extension Expiry: CustomStringConvertible {
    public var description: String {
        switch self {
        case .forever:
            return "forever"
        case .untilRestart:
            return "untilRestart"
        case .session:
            return "session"
        default:
            return "invalid"
        }
    }
}

