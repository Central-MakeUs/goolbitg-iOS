//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 6/20/25.
//

import ProjectDescription
import TuistExtensions

let buyOtNotDemoProject: Project = Project.create(
    config: ProjectConfig(
        name: DemoApps.buyOrNot.appName,
        product: .app,
        bundleID: DemoApps.buyOrNot.bundleID,
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
        , sources: DemoApps.buyOrNot.sourceFilesList
    ),
    subAppName: DemoApps.buyOrNot.appName
)
