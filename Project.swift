import ProjectDescription

let project = Project(
    name: "FidelLearn",
    organizationName: "FidelLearn",
    packages: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.10.0"),
    ],
    settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "Config.xcconfig"),
        .release(name: "Release", xcconfig: "Config.xcconfig"),
    ]),
    targets: [
        .target(
            name: "FidelLearn",
            destinations: .iOS,
            product: .app,
            bundleId: "com.fidellearn.app",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen",
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"],
                "CFBundleDisplayName": "Fidel Learn",
                "ITSAppUsesNonExemptEncryption": false,
                "NSMicrophoneUsageDescription": "Fidel Learn needs microphone access for pronunciation practice.",
                "UIBackgroundModes": ["audio"],
                "SUPABASE_URL": "$(SUPABASE_URL)",
                "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)",
            ]),
            sources: ["FidelLearn/Sources/**"],
            resources: ["FidelLearn/Resources/**"],
            dependencies: [
                .package(product: "Supabase", type: .runtime),
            ],
            settings: .settings(
                base: [
                    "SWIFT_STRICT_CONCURRENCY": "minimal",
                ]
            )
        ),
        .target(
            name: "FidelLearnTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.fidellearn.app.tests",
            deploymentTargets: .iOS("16.0"),
            sources: ["FidelLearnTests/Sources/**"],
            resources: ["FidelLearn/Resources/Data/**"],
            dependencies: [.target(name: "FidelLearn")]
        ),
        .target(
            name: "FidelLearnUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.fidellearn.app.uitests",
            deploymentTargets: .iOS("16.0"),
            sources: ["FidelLearnUITests/Sources/**"],
            dependencies: [.target(name: "FidelLearn")]
        ),
    ],
    schemes: [
        .scheme(
            name: "FidelLearn",
            shared: true,
            buildAction: .buildAction(targets: ["FidelLearn"]),
            testAction: .targets(
                ["FidelLearnTests", "FidelLearnUITests"],
                configuration: .debug
            ),
            runAction: .runAction(
                configuration: .debug,
                arguments: .arguments(
                    environmentVariables: [
                        "SUPABASE_URL": EnvironmentVariable(stringLiteral: "$(SUPABASE_URL)"),
                        "SUPABASE_ANON_KEY": EnvironmentVariable(stringLiteral: "$(SUPABASE_ANON_KEY)"),
                    ]
                ),
                expandVariableFromTarget: "FidelLearn"
            )
        ),
    ]
)
