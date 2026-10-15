// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FormCue",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FormCueDomain", targets: ["FormCueDomain"]),
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore"),
    ],
    targets: [
        .target(
            name: "FormCueDomain",
            dependencies: [
                .product(name: "AppRuntimeCore", package: "AppRuntimeCore"),
            ],
            path: "Sources/FormCueDomain"
        ),
    ]
)
