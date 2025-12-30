//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/23/25.
//

import TuistExtensions
import ProjectDescription

let myPageFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.MyPage).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            .domain,
            Module.feature(.Common).projectTarget,
            Module.Data.projectTarget,
            Module.utils.projectTarget,
            .tca,
            .tcaCoordinator,
            .popupView
        ],
        sources: [
            "Sources/**"
        ]
    )
)
