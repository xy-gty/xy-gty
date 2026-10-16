// swift-tools-version: 5.9
import PackageDescription

/// Private preparation scaffold: shared domain + local AppRuntimeCore dependency.
/// Formal Xcode host / visuals belong to later Builder; no UI targets here.
let package = Package(
    name: "HemlineDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HemlineDomain", targets: ["HemlineDomain"])
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore")
    ],
    targets: [
        .target(
            name: "HemlineDomain",
            dependencies: ["AppRuntimeCore"],
            path: "HemlineDomain"
        )
    ]
)
