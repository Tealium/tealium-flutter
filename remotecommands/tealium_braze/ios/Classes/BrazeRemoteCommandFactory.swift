//
//  BrazeRemoteCommandFactory.swift
//  tealium_braze
//
//  Created by James Keith on 15/01/2024.
//

import Foundation
import TealiumSwift
import TealiumBraze
import tealium

class BrazeRemoteCommandFactory: RemoteCommandFactory {
    var name: String = "BrazeRemoteCommand"
    
    func create() -> RemoteCommand {
        return BrazeRemoteCommand()
    }
}
