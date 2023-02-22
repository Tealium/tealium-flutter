//
//  OptionalModule.swift
//  tealium
//
//  Created by James Keith on 17/01/2023.
//

import Foundation
import TealiumSwift

public protocol OptionalModule {
    func configure(config: TealiumConfig) -> Void
}
