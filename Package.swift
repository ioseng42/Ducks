// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ducks",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Ducks",
            targets: ["Ducks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ioseng42/Ufos.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Ducks",
            dependencies: ["Ufos"]),
        .testTarget(
            name: "DucksTests",
            dependencies: ["Ducks", "Ufos"]),
    ]
)
