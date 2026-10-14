// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScoutCueDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ScoutCueDomain", targets: ["ScoutCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "ScoutCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/ScoutCueDomain"
        ),
    ]
)
