//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/23/25.
//

import TuistExtensions
import ProjectDescription

let tabTestTarget: Target = .target(
    name: "FeatureTabTests",
    destinations: AppConfig.destinations,
    product: .unitTests,
    bundleId: "com.frameWork.FeatureTabTests",
    deploymentTargets: AppConfig.deployTarget,
    sources: ["Tests/**"],
    dependencies: [
        .target(name: Module.feature(.Tab).frameWorkName)
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": "$(inherited) -ObjC"
        ]
    )
)

let tabFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.Tab).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        customTargets: [tabTestTarget],
        dependencies: [
            .tca,
            Module.Data.projectTarget
        ] + Module.tabNeedModules.map(\.projectTarget),
        sources: [
            "Sources/**"
        ]
    )
)
