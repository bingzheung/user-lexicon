// swift-tools-version: 5.7

import PackageDescription

let package = Package(
        name: "UserLexicon",
        targets: [
                .executableTarget(
                        name: "UserLexicon",
                        dependencies: []
                ),
                .testTarget(
                        name: "UserLexiconTests",
                        dependencies: ["UserLexicon"]
                )
        ]
)
