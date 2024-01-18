//
//  TealiumBrazePlugin.swift
//  tealium_braze
//
//  Created by James Keith on 15/01/2024.
//

import Flutter
import UIKit
import tealium

public class TealiumBrazePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      SwiftTealiumPlugin.registerRemoteCommandFactory(BrazeRemoteCommandFactory())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      result(FlutterMethodNotImplemented)
  }
}
