// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataTransferObjects",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DataTransferObjects",
            targets: ["DataTransferObjects"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/TelemetryDeck/SwiftDateOperations.git", from: "1.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DataTransferObjects",
            dependencies: [.product(name: "DateOperations", package: "SwiftDateOperations")]
        ),
        .testTarget(
            name: "DataTransferObjectsTests",
            dependencies: ["DataTransferObjects"]
        ),
        .testTarget(
            name: "QueryTests",
            dependencies: ["DataTransferObjects"]
        ),
        .testTarget(
            name: "QueryResultTests",
            dependencies: ["DataTransferObjects"]
        ),
        .testTarget(
            name: "QueryGenerationTests",
            dependencies: ["DataTransferObjects"]
        ),
    ]
)
