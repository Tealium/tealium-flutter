//
//  BrazeRemoteCommandFactory.swift
//  tealium_braze
//
//  Created by James Keith on 15/01/2024.
//

import Foundation
import TealiumBraze
import tealium

#if SWIFT_PACKAGE
    import TealiumRemoteCommands
#else
    import TealiumSwift
#endif

class BrazeRemoteCommandFactory: RemoteCommandFactory {
    var name: String = "BrazeRemoteCommand"

    func create() -> RemoteCommand {
        return BrazeRemoteCommand()
    }
}
