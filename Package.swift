// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StopCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "StopCueDomain", targets: ["StopCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "StopCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/StopCueDomain"
        ),
    ]
)
