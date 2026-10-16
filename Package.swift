// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Broodcheck",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BroodcheckDomain", targets: ["BroodcheckDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "BroodcheckDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/BroodcheckDomain"
        ),
    ]
)
