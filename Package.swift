// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PitchCueDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "PitchCueDomain", targets: ["PitchCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "PitchCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/PitchCueDomain"
        ),
    ]
)
