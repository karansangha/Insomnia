// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Insomnia",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Insomnia", targets: ["Insomnia"]),
        .library(name: "InsomniaCore", targets: ["InsomniaCore"])
    ],
    targets: [
        .target(
            name: "InsomniaCore"
        ),
        .executableTarget(
            name: "Insomnia",
            dependencies: ["InsomniaCore"],
            exclude: ["Info.plist", "insomnia.entitlements"],
            resources: [.process("Assets.xcassets")]
        ),
        .testTarget(
            name: "InsomniaTests",
            dependencies: ["InsomniaCore"]
        )
    ]
)
