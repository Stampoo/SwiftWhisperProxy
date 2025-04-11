// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftWhisperProxy",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "SwiftWhisperProxy",
            targets: [
                "SwiftWhisperProxy"
            ]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "WhisperFramework",
            url: "https://github.com/ggml-org/whisper.cpp/releases/download/v1.7.5/whisper-v1.7.5-xcframework.zip",
            checksum: "c7faeb328620d6012e130f3d705c51a6ea6c995605f2df50f6e1ad68c59c6c4a"
        ),
        .target(
            name: "SwiftWhisperProxy",
            dependencies: [
                "WhisperFramework"
            ]
        ),
        .testTarget(
            name: "SwiftWhisperProxyTests",
            dependencies: ["SwiftWhisperProxy"]
        ),
    ]
)
