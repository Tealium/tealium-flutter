//
//  OptionalModule.swift
//  tealium
//
//  Created by James Keith on 17/01/2023.
//

import Foundation

#if SWIFT_PACKAGE
    import TealiumCore
#else
    import TealiumSwift
#endif

public protocol OptionalModule {
    func configure(config: TealiumConfig)
}
