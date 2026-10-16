// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Onionreel",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "OnionreelDomain", targets: ["OnionreelDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "OnionreelDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/OnionreelDomain"
        ),
    ]
)
