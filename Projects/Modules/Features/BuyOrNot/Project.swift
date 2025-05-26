//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/23/25.
//

import TuistExtensions
import ProjectDescription

let buyOrNotFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.BuyOrNot).frameWorkName,
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
