//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/26/25.
//

import TuistExtensions
import ProjectDescription

let onlyHomeProject = Project.create(
    config: ProjectConfig(
        name: DemoApps.home.appName,
        product: .app,
        bundleID: DemoApps.home.bundleID,
        deploymentTargets: AppConfig.deployTarget,
        schemes: [],
        dependencies: Module.features.map(\.projectTarget) + [
            Module.utils.projectTarget,
            Module.Data.projectTarget,
            .tca,
            .tcaCoordinator,
//            .firebaseCore,
//            .firebaseMessaging,
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
        , sources: DemoApps.home.sourceFilesList
    ),
    subAppName: DemoApps.home.appName
)
