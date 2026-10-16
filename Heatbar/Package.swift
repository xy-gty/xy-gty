// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Heatbar",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HeatbarDomain", targets: ["HeatbarDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "HeatbarDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/HeatbarDomain"
        ),
    ]
)
