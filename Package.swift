// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FrameCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FrameCueDomain", targets: ["FrameCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "FrameCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/FrameCueDomain"
        ),
    ]
)
