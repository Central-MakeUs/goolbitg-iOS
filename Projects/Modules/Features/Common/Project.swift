//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/22/25.
//

import TuistExtensions
import ProjectDescription

let commonFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.Common).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
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
