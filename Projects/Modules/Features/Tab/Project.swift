//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/23/25.
//

import TuistExtensions
import ProjectDescription

let tabFremeWork = Project.create(
    config: FrameworkConfig(
        name: Module.feature(.Tab).frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            .tca,
            .tcaCoordinator
        ] + Module.tabNeedModules.map(\.projectTarget),
        sources: [
            "Sources/**"
        ]
    )
)
