// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YarnCuePreparation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "YarnCueDomain", targets: ["YarnCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "YarnCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/YarnCueDomain"
        ),
    ]
)
