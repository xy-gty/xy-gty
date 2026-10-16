// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Shutterdusk",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ShutterduskDomain", targets: ["ShutterduskDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "ShutterduskDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/ShutterduskDomain"
        ),
    ]
)
