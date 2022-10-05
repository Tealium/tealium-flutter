//
//  FirebaseRemoteCommandFactory.swift
//  tealium
//
//  Created by James Keith on 09/09/2022.
//

import Foundation
import TealiumSwift
import TealiumFirebase
import tealium

class FirebaseRemoteCommandFactory: RemoteCommandFactory {
    var name: String = "FirebaseRemoteCommand"
    
    func create() -> RemoteCommand {
        return FirebaseRemoteCommand()
    }
}
