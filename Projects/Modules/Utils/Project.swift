//
//  Project.swift
//  AppManifests
//
//  Created by Jae hyung Kim on 5/21/25.
//

import ProjectDescription
import TuistExtensions

let utilsFrameWork = Project.create(
    config: FrameworkConfig(
        name: Module.utils.frameWorkName,
        deploymentTargets: AppConfig.deployTarget,
        dependencies: [
            .domain,
            .tca,
            .swiftyBeaver,
            .kingfisher,
            .kakaoSDK,
//            .swiftyGif,
            .gifu,
            .lottie,
            .fireBaseCrashlytics,
            .firebaseCore,
            .firebaseMessaging,
            .fireBaseAnalytics,
            .imageCompressor
        ],
        resources: [
            "Resources/**"
        ],
        sources: [
            "Sources/**"
        ]
    )
)
