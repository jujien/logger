// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .macCatalyst(.v15),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "Logger", targets: ["Logger"])
    ],
    targets: [
        .target(name: "Logger"),
        .testTarget(name: "LoggerTests", dependencies: ["Logger"])
    ]
)
