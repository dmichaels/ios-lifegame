// Nevermind. This does not work. Wanted to import Utils into command-line test script
// but cannot because Utils contains UIKit and @MainActor et cetera.

// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TestConfig",
    dependencies: [
        .package(path: "../../../ios-utils/Utils")
    ],
    targets: [
        .executableTarget( // 👈 change .target to .executableTarget
            name: "TestConfig",
            dependencies: ["Utils"]
        )
    ]
)
