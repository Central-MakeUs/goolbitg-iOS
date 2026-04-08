//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/22/25.
//

import TuistExtensions
import ProjectDescription

let commonTestTarget: Target = .target(
    name: "FeatureCommonTests",
    destinations: AppConfig.destinations,
    product: .unitTests,
    bundleId: "com.frameWork.FeatureCommonTests",
    deploymentTargets: AppConfig.deployTarget,
    sources: ["Tests/**"],
    dependencies: [
        .target(name: Module.feature(.Common).frameWorkName)
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": "$(inherited) -ObjC"
        ]
    )
)

let commonFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.Common).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        customTargets: [commonTestTarget],
        dependencies: [
            Module.utils.projectTarget,
            Module.Data.projectTarget,
            .domain,
            .kingfisher,
            .popupView
        ],
        sources: [
            "Sources/**"
        ]
    )
)
