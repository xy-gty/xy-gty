// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Racknote",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "RacknoteDomain", targets: ["RacknoteDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "RacknoteDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/RacknoteDomain"
        ),
    ]
)
