//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/22/25.
//

import TuistExtensions
import ProjectDescription

let introFramework = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.Intro).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            Module.Data.projectTarget,
            Module.utils.projectTarget,
            Module.feature(.Common).projectTarget,
            .tca,
            .tcaCoordinator,
            .kingfisher,
            .popupView
        ],
        sources: [
            "Sources/**"
        ]
    )
)
