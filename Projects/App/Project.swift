//
//  Project.swift
//  Config
//
//  Created by Jae hyung Kim on 5/21/25.
//

import TuistExtensions
import ProjectDescription

let project = Project.create(
    config: ProjectConfig(
        name: "App",
        product: .app,
        deploymentTargets: AppConfig.deployTarget,
        schemes: [], // SchemeMode.getSchemes(targetName: "App", path: "App"),
        dependencies: Module.features.map(\.projectTarget) + [
            Module.utils.projectTarget,
            Module.Data.projectTarget,
            .tca,
            .tcaCoordinator,
            .firebaseCore,
            .firebaseMessaging,
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
        , sources: "Sources/**"
    )
)
// SchemeMode.getSchemes(targetName: "App", path: AppConfig.appPath)
