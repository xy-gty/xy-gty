// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RuleCuePreparation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "RuleCueDomain", targets: ["RuleCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "RuleCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/RuleCueDomain"
        ),
    ]
)
