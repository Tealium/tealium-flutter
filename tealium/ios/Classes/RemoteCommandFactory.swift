//
//  RemoteCommandFactory.swift
//  tealium
//
//  Created by James Keith on 09/09/2022.
//

import Foundation
import TealiumSwift

public protocol RemoteCommandFactory {
    var name: String { get }
    func create() -> RemoteCommand
}
