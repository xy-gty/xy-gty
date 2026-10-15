// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FinishCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FinishCueDomain", targets: ["FinishCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "FinishCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/FinishCueDomain"
        ),
    ]
)
