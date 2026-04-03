//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/21/25.
//

import TuistExtensions
import ProjectDescription

let dataTestTarget: Target = .target(
    name: "DataTests",
    destinations: AppConfig.destinations,
    product: .unitTests,
    bundleId: "com.frameWork.DataTests",
    deploymentTargets: AppConfig.deployTarget,
    sources: ["Tests/**"],
    dependencies: [
        .target(name: Module.Data.frameWorkName)
    ]
)

let dataFramework = Project.create(
    config: FrameworkConfig(
        name: Module.Data.frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        customTargets: [dataTestTarget],
        dependencies: [
            Module.utils.projectTarget,
            .domain,
            .tca,
            .alamofire,
            .swiftyBeaver,
            .socketIO,
//            .jwtToken
        ],
        sources: ["Sources/**"]
    )
)
