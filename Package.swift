// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LocalizationKit",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "LocalizationKit",
            targets: ["LocalizationKit"]
        ),
    ],
    targets: [
        .target(
            name: "LocalizationKit",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "LocalizationKitTests",
            dependencies: ["LocalizationKit"]
        ),
    ]
)
