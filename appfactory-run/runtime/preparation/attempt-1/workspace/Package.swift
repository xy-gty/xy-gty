// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WingCuePreparation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WingCueDomain", targets: ["WingCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "WingCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/WingCueDomain"
        ),
    ]
)
