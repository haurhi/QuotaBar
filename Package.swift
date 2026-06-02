// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QuotaBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "QuotaBar",
            targets: ["QuotaBar"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "QuotaBar",
            path: "QuotaBar",
            exclude: ["Info.plist", "QuotaBar.entitlements", "Preview Content"],
            resources: [
                .process("Assets.xcassets"),
                .copy("Resources")
            ]
        )
    ]
)
