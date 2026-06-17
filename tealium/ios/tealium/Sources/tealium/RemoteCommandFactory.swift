//
//  RemoteCommandFactory.swift
//  tealium
//
//  Created by James Keith on 09/09/2022.
//

import Foundation

#if SWIFT_PACKAGE
    import TealiumRemoteCommands
#else
    import TealiumSwift
#endif

public protocol RemoteCommandFactory {
    var name: String { get }
    func create() -> RemoteCommand
}
