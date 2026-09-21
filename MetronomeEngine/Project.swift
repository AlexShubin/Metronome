import ProjectDescription

let project = Project(
    name: "MetronomeEngine",
    options: .options(automaticSchemesOptions: .enabled(codeCoverageEnabled: true)),
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "DEVELOPMENT_TEAM": "",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "MetronomeEngine",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "com.alexshubin.Metronome.MetronomeEngine",
            deploymentTargets: .macOS("26.0"),
            buildableFolders: [
                "Sources",
                "Resources",
            ]
        ),
        .target(
            name: "MetronomeEngineTestSupport",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "com.alexshubin.Metronome.MetronomeEngineTestSupport",
            deploymentTargets: .macOS("26.0"),
            buildableFolders: [
                "TestSupport",
            ],
            dependencies: [
                .target(name: "MetronomeEngine"),
            ]
        ),
        .target(
            name: "MetronomeEngineTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.alexshubin.Metronome.MetronomeEngineTests",
            deploymentTargets: .macOS("26.0"),
            buildableFolders: [
                "Tests",
            ],
            dependencies: [
                .target(name: "MetronomeEngine"),
            ]
        ),
    ]
)
