// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SnagCuePreparation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SnagCueDomain", targets: ["SnagCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "SnagCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/SnagCueDomain"
        ),
    ]
)
