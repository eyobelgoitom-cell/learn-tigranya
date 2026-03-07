import ProjectDescription

let project = Project(
    name: "FidelLearn",
    organizationName: "FidelLearn",
    options: .options(
        automaticSchemesOrdering: true,
        disableBundleAccessors: false,
        disableSynthesizedResourceAccessors: false
    ),
    packages: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.10.0"),
    ],
    targets: [
        .target(
            name: "FidelLearn",
            destinations: .iOS,
            product: .app,
            bundleId: "com.fidellearn.app",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "",
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"],
                "CFBundleDisplayName": "Fidel Learn",
                "ITSAppUsesNonExemptEncryption": false,
                "NSMicrophoneUsageDescription": "Fidel Learn needs microphone access for pronunciation practice.",
                "UIBackgroundModes": ["audio"],
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
            runAction: .runAction(configuration: .debug)
        ),
    ]
)
