// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HiveCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HiveCueDomain", targets: ["HiveCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "HiveCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/HiveCueDomain"
        ),
    ]
)
