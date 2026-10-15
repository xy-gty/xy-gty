// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CellarCuePreparation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CellarCueDomain", targets: ["CellarCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "CellarCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/CellarCueDomain"
        ),
    ]
)
