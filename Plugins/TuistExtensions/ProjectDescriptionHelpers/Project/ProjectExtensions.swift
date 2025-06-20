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
                    name: subAppName ?? "App",
                    destinations: AppConfig.destinations,
                    product: config.product,
                    bundleId: config.bundleId ?? "$(PRODUCT_BUNDLE_IDENTIFIER)",
                    deploymentTargets: config.deploymentTargets,
                    infoPlist: .file(
                        path: Path.onesPlistName()
                    ),
                    sources: config.sources,
                    resources: config.resources,
                    entitlements: appEntitlementsPath,
                    dependencies: config.dependencies
                )
            ]
            let name = subAppName ?? config.name
            
            return Project(
                name: name,
                packages: config.packages,
                settings: subAppName == nil ? .appSettings : .demoAppSetting(name: subAppName!),
                targets: targets + config.customTargets,
                schemes: Scheme.schemes(name: name, root: subAppName == nil),
                resourceSynthesizers: [
                    .custom(name: "Assets", parser: .assets, extensions: ["xcassets"]),
                    .custom(name: "Fonts", parser: .fonts, extensions: ["otf"]),
                ]
            )
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
            
            return Project(
                name: config.name,
                packages: config.packages,
                settings: .appSettings,
                targets: targets + config.customTargets,
                schemes: config.schemes,
                resourceSynthesizers: [
                    .custom(name: "Assets", parser: .assets, extensions: ["xcassets"]),
                    .custom(name: "Fonts", parser: .fonts, extensions: ["otf"]),
                ]
            )
        default:
            fatalError()
        }
    }
}
