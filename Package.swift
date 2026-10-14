// swift-tools-version: 5.9
import PackageDescription

/// Private preparation scaffold: shared domain + local AppRuntimeCore dependency.
/// Formal Xcode host / visuals belong to later Builder; no UI targets here.
let package = Package(
    name: "BendCoachDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BendCoachDomain", targets: ["BendCoachDomain"])
    ],
    dependencies: [
        .package(path: "Vendor/AppRuntimeCore")
    ],
    targets: [
        .target(
            name: "BendCoachDomain",
            dependencies: ["AppRuntimeCore"],
            path: "BendCoachDomain"
        )
    ]
)
