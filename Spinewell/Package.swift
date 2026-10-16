// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Spinewell",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SpinewellDomain", targets: ["SpinewellDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "SpinewellDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/SpinewellDomain"
        ),
    ]
)
