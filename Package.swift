// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AssetKit",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(name: "assetool", targets: ["assetool"]),
        .library(name: "AssetKit", targets: ["AssetKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AssetKit",
            dependencies: [],
            path: "Sources/AssetKit",
            resources: [
                .process("Resources"),
            ]),
        .executableTarget(
            name: "assetool",
            dependencies: [
                "AssetKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/assetool"),
        .testTarget(
            name: "AssetKitTests",
            dependencies: ["AssetKit"]),
    ]
)
