//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 12/4/25.
//

import ProjectDescription
import TuistExtensions

let introProject = Project.create(
    config: ProjectConfig(
        name: DemoApps.intro.appName,
        product: .app,
        bundleID: DemoApps.intro.bundleID,
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
        , sources: DemoApps.intro.sourceFilesList
    ),
    subAppName: DemoApps.intro.appName
)
