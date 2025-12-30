//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/22/25.
//

import TuistExtensions
import ProjectDescription


let domainFramework = Project.create(
    config: FrameworkConfig(
        name: DomainConfig.frameworkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            .alamofire
        ],
        sources: [
            "Sources/**"
        ]
    )
)
