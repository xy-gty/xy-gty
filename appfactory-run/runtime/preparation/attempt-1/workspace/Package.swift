// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CuePartnerPreparation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CuePartnerDomain", targets: ["CuePartnerDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "CuePartnerDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/CuePartnerDomain"
        ),
    ]
)
