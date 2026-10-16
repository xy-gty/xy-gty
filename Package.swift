// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CountroomDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CountroomDomain", targets: ["CountroomDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "CountroomDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/CountroomDomain"
        ),
    ]
)
