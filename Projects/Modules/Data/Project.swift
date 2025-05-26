//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/21/25.
//

import TuistExtensions
import ProjectDescription

let dataFramework = Project.create(
    config: FrameworkConfig(
        name: Module.Data.frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            Module.utils.projectTarget,
            .domain,
            .tca,
            .alamofire,
            .swiftyBeaver,
            .jwtToken
        ],
        sources: ["Sources/**"]
    )
)
