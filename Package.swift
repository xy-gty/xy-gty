// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mattebox",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MatteboxDomain", targets: ["MatteboxDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "MatteboxDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/MatteboxDomain"
        ),
    ]
)
