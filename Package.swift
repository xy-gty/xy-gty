// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Tablehost",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TablehostDomain", targets: ["TablehostDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "TablehostDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/TablehostDomain"
        ),
    ]
)
