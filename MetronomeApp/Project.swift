import ProjectDescription

let appVersion = "1.0.0"
let buildNumber = "1"

let project = Project(
    name: "MetronomeApp",
    options: .options(automaticSchemesOptions: .enabled(codeCoverageEnabled: true)),
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": "RBNKHS73S3",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "MetronomeApp",
            destinations: .macOS,
            product: .app,
            bundleId: "com.alexshubin.Metronome",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleIconName": "AppIcon",
                "CFBundleDisplayName": "Metronome",
                "CFBundleName": "Metronome",
                "CFBundleShortVersionString": .string(appVersion),
                "CFBundleVersion": .string(buildNumber),
                "LSApplicationCategoryType": "public.app-category.music",
                "ITSAppUsesNonExemptEncryption": false,
            ]),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            entitlements: .file(path: "Resources/MetronomeApp.entitlements"),
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ENABLE_APP_SANDBOX": "YES",
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "PRODUCT_NAME": "Metronome",
                    "PRODUCT_MODULE_NAME": "MetronomeApp",
                    "MARKETING_VERSION": .string(appVersion),
                    "CURRENT_PROJECT_VERSION": .string(buildNumber),
                ]
            )
        ),
        .target(
            name: "MetronomeAppTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.alexshubin.Metronome.MetronomeAppTests",
            deploymentTargets: .macOS("26.0"),
            buildableFolders: [
                "Tests",
            ],
            dependencies: [
                .target(name: "MetronomeApp"),
            ],
            settings: .settings(
                base: [
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Metronome.app/Contents/MacOS/Metronome",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                ]
            )
        ),
    ]
)
