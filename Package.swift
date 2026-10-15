// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LuxCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LuxCueDomain", targets: ["LuxCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "LuxCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/LuxCueDomain"
        ),
    ]
)
