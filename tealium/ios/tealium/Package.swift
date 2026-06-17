// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tealium",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "tealium", targets: ["tealium"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/tealium/tealium-swift", from: "2.18.0")
    ],
    targets: [
        .target(
            name: "tealium",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TealiumCore", package: "tealium-swift"),
                .product(name: "TealiumTagManagement", package: "tealium-swift"),
                .product(name: "TealiumCollect", package: "tealium-swift"),
                .product(name: "TealiumLifecycle", package: "tealium-swift"),
                .product(name: "TealiumRemoteCommands", package: "tealium-swift"),
                .product(name: "TealiumVisitorService", package: "tealium-swift")
            ]
        )
    ]
)
