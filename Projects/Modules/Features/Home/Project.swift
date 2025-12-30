//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/21/25.
//

import TuistExtensions
import ProjectDescription

let homeFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.Home).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            Module.feature(.Common).projectTarget,
            .tca,
            .tcaCoordinator,
            .popupView
        ],
        sources: [
            "Sources/**"
        ]
    )
)

//"Sources/**"
