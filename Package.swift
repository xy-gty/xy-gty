// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FolioCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FolioCueDomain", targets: ["FolioCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "FolioCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/FolioCueDomain"
        ),
    ]
)
