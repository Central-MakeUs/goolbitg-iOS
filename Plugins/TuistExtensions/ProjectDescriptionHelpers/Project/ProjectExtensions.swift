//
//  ProjectExtensions.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/18/25.
//

import ProjectDescription

private let appEntitlementsPath: Entitlements = .file(
    path: .relativeToRoot(
        "AppSettingFiles/Entitlements/\(AppConfig.noTuistAppName).entitlements"
    )
)

extension Project {
    
    public static func create(config: ProjectConfigProtocol, subAppName: String? = nil) -> Project {
        var targets: [Target] = []
        switch config.product {
        case .app:
            targets = [
                .target( // 단일 타켓 여러 스킴
                    name: subAppName == nil ? "App" : subAppName!,
                    destinations: AppConfig.destinations,
                    product: config.product,
                    bundleId: config.bundleId == nil ? "\(AppConfig.bundleID)" : config.bundleId!,
                    deploymentTargets: config.deploymentTargets,
                    infoPlist: .file(
                        path: Path.onesPlistName()
                    ),
                    sources: config.sources,
                    resources: config.resources,
                    entitlements: appEntitlementsPath,
                    dependencies: config.dependencies,
                    settings: .settings(
                        base: AppConfig.baseSettings,
                        configurations: [

                        ]
                    )
                ),
                
            ]
            
            if subAppName == nil {
                targets.append(
                    .target( // 단일 타켓 여러 스킴
                        name: "DEV",
                        destinations: AppConfig.destinations,
                        product: config.product,
                        bundleId: "\(AppConfig.bundleID)",
                        deploymentTargets: config.deploymentTargets,
                        infoPlist: .file(
                            path: Path.onesPlistName()
                        ),
                        sources: config.sources,
                        resources: config.resources,
                        entitlements: appEntitlementsPath,
                        dependencies: config.dependencies,
                        settings: .settings(
                            base: AppConfig.baseSettings,
                            configurations: [
                                .debug(
                                    name: SchemeMode.dev.runActionConfiguration,
                                    settings: [
                                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "\(SchemeMode.dev.schemeName)"
                                    ]
                                )
                            ]
                        )
                    )
                )
                
                targets.append(
                    .target( // 단일 타켓 여러 스킴
                        name: "STAGE",
                        destinations: AppConfig.destinations,
                        product: config.product,
                        bundleId: "\(AppConfig.bundleID)",
                        deploymentTargets: config.deploymentTargets,
                        infoPlist: .file(
                            path: Path.onesPlistName()
                        ),
                        sources: config.sources,
                        resources: config.resources,
                        entitlements: appEntitlementsPath,
                        dependencies: config.dependencies,
                        settings: .settings(
                            base: AppConfig.baseSettings,
                            configurations: [
                                .debug(
                                    name: SchemeMode.stage.runActionConfiguration,
                                    settings: [
                                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "\(SchemeMode.stage.schemeName)"
                                    ]
                                )
                            ]
                        )
                    )
                )
            }
            
        case .framework:
            targets = [
                .target(
                    name: config.name,
                    destinations: AppConfig.destinations,
                    product: config.product,
                    bundleId: "com.frameWork.\(config.name)",
                    deploymentTargets: config.deploymentTargets,
                    sources: config.sources,
                    resources: config.resources,
                    scripts: config.scripts,
                    dependencies: config.dependencies
                )
            ]
        default:
            fatalError()
        }
        
        return Project(
            name: config.name,
            packages: config.packages,
            targets: targets + config.customTargets,
            schemes: config.schemes,
            resourceSynthesizers: [
                .custom(name: "Assets", parser: .assets, extensions: ["xcassets"]),
                .custom(name: "Fonts", parser: .fonts, extensions: ["otf"]),
            ]
        )
    }
}


//                            .release(
//                                name: SchemeMode.stage.runActionConfiguration,
//                                settings: [
//                                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "\(SchemeMode.stage.schemeName)"
//                                ]
//                            )
//                            , .release(
//                                name: SchemeMode.live.runActionConfiguration,
//                                settings: [
//                                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "\(SchemeMode.live.schemeName)"
//                                ]
//                            )
