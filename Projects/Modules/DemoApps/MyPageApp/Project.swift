//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 6/20/25.
//

import ProjectDescription
import TuistExtensions

let onlyMyPageProject = Project.create(
    config: ProjectConfig(
        name: DemoApps.myPage.appName,
        product: .app,
        bundleID: DemoApps.myPage.bundleID,
        deploymentTargets: AppConfig.deployTarget,
        schemes: [],
        dependencies: Module.features.map(\.projectTarget) + [
            .domain,
            Module.Data.projectTarget,
            Module.utils.projectTarget,
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
        , sources: DemoApps.myPage.sourceFilesList
    ),
    subAppName: DemoApps.myPage.appName
)
