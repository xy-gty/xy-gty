// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LoopwellDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LoopwellDomain", targets: ["LoopwellDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "LoopwellDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/LoopwellDomain"
        ),
    ]
)
