// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Fieldmark",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FieldmarkDomain", targets: ["FieldmarkDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "FieldmarkDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/FieldmarkDomain"
        ),
    ]
)
