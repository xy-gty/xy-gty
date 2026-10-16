// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BrewCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BrewCueDomain", targets: ["BrewCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "BrewCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/BrewCueDomain"
        ),
    ]
)
