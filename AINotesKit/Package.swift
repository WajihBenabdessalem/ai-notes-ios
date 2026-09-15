// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "AINotesKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AINotesKit", targets: ["AINotesKit"])
    ],
    targets: [
        .target(name: "AINotesKit"),
        .testTarget(name: "AINotesKitTests", dependencies: ["AINotesKit"]),
    ]
)
