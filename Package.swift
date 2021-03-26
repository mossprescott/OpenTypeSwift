// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OpenTypeSwift",
    products: [
        .library(
            name: "OpenTypeSwift",
            targets: ["OpenTypeSwift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "OpenTypeSwift",
            dependencies: []),
        .testTarget(
            name: "OpenTypeSwiftTests",
            dependencies: ["OpenTypeSwift"]),
    ]
)
