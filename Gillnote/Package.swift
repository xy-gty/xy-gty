// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Gillnote",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "GillnoteDomain", targets: ["GillnoteDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "GillnoteDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/GillnoteDomain"
        ),
    ]
)
