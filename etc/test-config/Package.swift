import PackageDescription

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
