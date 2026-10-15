// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SporeCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SporeCueDomain", targets: ["SporeCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "SporeCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/SporeCueDomain"
        ),
    ]
)
