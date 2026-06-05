// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QuotaRadar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "QuotaRadar",
            targets: ["QuotaRadar"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "QuotaRadar",
            path: "QuotaRadar",
            exclude: ["Info.plist", "QuotaRadar.entitlements", "Preview Content"],
            resources: [
                .process("Assets.xcassets"),
                .copy("Resources")
            ]
        )
    ]
)
