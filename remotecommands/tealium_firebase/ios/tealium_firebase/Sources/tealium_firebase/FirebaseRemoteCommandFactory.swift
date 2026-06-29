//
//  FirebaseRemoteCommandFactory.swift
//  tealium
//
//  Created by James Keith on 09/09/2022.
//

import Foundation
import TealiumFirebase
import tealium

#if SWIFT_PACKAGE
    import TealiumRemoteCommands
#else
    import TealiumSwift
#endif

class FirebaseRemoteCommandFactory: RemoteCommandFactory {
    var name: String = "FirebaseRemoteCommand"

    func create() -> RemoteCommand {
        return FirebaseRemoteCommand()
    }
}
