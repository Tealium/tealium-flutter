// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tealium_moments_api",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "tealium-moments-api", targets: ["tealium_moments_api"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Sibling Flutter plugin: the native code does `import tealium`. The Flutter
        // tool rewrites this relative path to the versioned symlink at build time, so
        // it resolves both in this monorepo and when consumed from pub.dev.
        .package(name: "tealium", path: "../tealium"),
        .package(url: "https://github.com/tealium/tealium-swift", .upToNextMajor(from: "2.18.3"))
    ],
    targets: [
        .target(
            name: "tealium_moments_api",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "tealium", package: "tealium"),
                .product(name: "TealiumCore", package: "tealium-swift"),
                .product(name: "TealiumMomentsAPI", package: "tealium-swift")
            ],

        )
    ]
)
