//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/26/25.
//

import TuistExtensions
import ProjectDescription

let onlyChallengeProject = Project.create(
    config: ProjectConfig(
        name: DemoApps.challenge.appName,
        product: .app,
        bundleID: DemoApps.challenge.bundleID,
        deploymentTargets: AppConfig.deployTarget,
        schemes: [],
        dependencies: Module.features.map(\.projectTarget) + [
            Module.utils.projectTarget,
            Module.Data.projectTarget,
            .tca,
            .tcaCoordinator,
            .popupView
        ],
        resources: [
            .glob(
                pattern: .relativeToRoot("AppSettingFiles/AppResources/**"),
                excluding: [],
                tags: [],
                inclusionCondition: nil
            )
        ]
        , sources: DemoApps.challenge.sourceFilesList
    ),
    subAppName: DemoApps.challenge.appName
)
