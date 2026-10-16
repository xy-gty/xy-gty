// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SunbriefDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SunbriefDomain", targets: ["SunbriefDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "SunbriefDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/SunbriefDomain"
        ),
    ]
)
