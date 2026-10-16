// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppRuntimeCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "AppRuntimeCore", targets: ["AppRuntimeCore"])],
    targets: [.target(name: "AppRuntimeCore")]
)
