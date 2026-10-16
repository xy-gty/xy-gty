// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Bloomkettle",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BloomkettleDomain", targets: ["BloomkettleDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "BloomkettleDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/BloomkettleDomain"
        ),
    ]
)
