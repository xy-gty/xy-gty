// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Workrest",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WorkrestDomain", targets: ["WorkrestDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "WorkrestDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/WorkrestDomain"
        ),
    ]
)
