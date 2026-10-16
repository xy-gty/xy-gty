// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Stirboard",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "StirboardDomain", targets: ["StirboardDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "StirboardDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/StirboardDomain"
        ),
    ]
)
