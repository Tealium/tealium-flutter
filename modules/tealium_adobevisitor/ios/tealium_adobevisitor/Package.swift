// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tealium_adobevisitor",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "tealium-adobevisitor", targets: ["tealium_adobevisitor"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Sibling Flutter plugin: the native code does `import tealium`. The Flutter
        // tool rewrites this relative path to the versioned symlink at build time, so
        // it resolves both in this monorepo and when consumed from pub.dev.
        .package(name: "tealium", path: "../tealium"),
        .package(url: "https://github.com/tealium/tealium-swift", from: "2.18.0"),
        .package(url: "https://github.com/tealium/tealium-swift-adobe-visitor-api", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "tealium_adobevisitor",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "tealium", package: "tealium"),
                .product(name: "TealiumCore", package: "tealium-swift"),
                .product(name: "TealiumAdobeVisitorAPI", package: "tealium-swift-adobe-visitor-api")
            ]
        )
    ]
)
