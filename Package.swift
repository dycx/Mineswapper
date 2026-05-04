// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mineswapper",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Mineswapper",
            path: "Mineswapper"
        ),
        .testTarget(
            name: "MineswapperTests",
            dependencies: ["Mineswapper"],
            path: "MineswapperTests"
        )
    ]
)
