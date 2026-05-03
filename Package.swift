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
            name: "InsomniaCore",
            path: "insomnia",
            exclude: ["InsomniaApp.swift", "UpdateChecker.swift", "Intents.swift", "Info.plist", "insomnia.entitlements", "Assets.xcassets"]
        ),
        .executableTarget(
            name: "Insomnia",
            dependencies: ["InsomniaCore"],
            path: "insomnia",
            exclude: ["SleepManager.swift", "Info.plist", "insomnia.entitlements"],
            resources: [.process("Assets.xcassets")]
        ),
        .testTarget(
            name: "InsomniaTests",
            dependencies: ["InsomniaCore"]
        )
    ]
)
