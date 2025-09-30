//
//  SchemeMode.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/18/25.
//

import ProjectDescription
import Foundation

// Example) TUIST_MODE=Dev tuist generate
public var getProjectScheme: SchemeMode {
    let schemeString = ProcessInfo.processInfo.environment["TUIST_MODE"] ?? "Dev"
    let result = SchemeMode.getSelf(schemeString: schemeString) ?? .dev
    return result
}

public enum SchemeMode: CaseIterable {
    case dev
    case stage
    case live
    
    public var schemeName: String {
        switch self {
        case .dev:
            return "Dev"
        case .live:
            return "Live"
        case .stage:
            return "Stage"
        }
    }
    
    public static func getSelf(schemeString: String) -> SchemeMode? {
        return SchemeMode.allCases.first { $0.schemeName == schemeString }
    }

    public var infoPlist: String {
        return self.schemeName + ".Plist"
    }
}

extension Path {
    
    public static func onesPlistName() -> Path {
        return .relativeToRoot("AppSettingFiles/InfoPlist/Info.Plist")
    }
    
    public static func xcconfigPath(_ xcconfigName: String) -> Path {
        .relativeToRoot("AppSettingFiles/XCConfigs/\(xcconfigName).xcconfig")
    }

}

extension Settings {
    
    public static var appSettings: Self {
        return .settings(
            base: [
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
//                "SWIFT_VERSION": "6.0" Swift GIF 라이브러리에서 문제 발생
                // TODO: Swift GIF 대체제를 찾거나 만들어서 해결할것
            ],
            configurations: [
                .debug,
                .release,
                .dev,
                .stage
            ]
        )
    }
    
    public static func demoAppSetting(name: String) -> Self {
        return .settings(
            base: [
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "DISPLAY_NAME" : "\(name)",
//                "SWIFT_VERSION": "6.0"
            ],
            configurations: [
                .debug,
                .release,
                .dev,
                .stage
            ]

        )
    }
}

extension Scheme {
    
    public static func schemes(name: String, root: Bool = true) -> [Self] {
        var targets: [TargetReference] = []
        if root {
            targets.append("App")
            
            return [
                .scheme( // Dev
                    name: name + "_DEV",
                    shared: true,
                    hidden: false,
                    buildAction: .buildAction(targets: targets),
                    runAction: .runAction(configuration: .dev),
                    archiveAction: .archiveAction(configuration: .dev),
                    profileAction: .profileAction(configuration: .dev),
                    analyzeAction: .analyzeAction(configuration: .dev)
                ),
                .scheme(
                    name: name + "_Stage",
                    shared: true,
                    hidden: false,
                    buildAction: .buildAction(targets: targets),
                    runAction: .runAction(configuration: .stage),
                    archiveAction: .archiveAction(configuration: .stage),
                    profileAction: .profileAction(configuration: .stage),
                    analyzeAction: .analyzeAction(configuration: .stage)
                )
            ]
        }
        else {
            return []
        }
    }
}

extension ConfigurationName {
    
    public static let dev: Self = .configuration(SchemeMode.dev.schemeName)
    
    public static let stage: Self = .configuration(SchemeMode.stage.schemeName)
    
    public static let live: Self = .configuration(SchemeMode.live.schemeName)
}

extension Configuration {
    public static let debug: Self = .debug(name: "Debug", xcconfig: .xcconfigPath("Debug"))
    public static let release: Self = .debug(name: "Release", xcconfig: .xcconfigPath("Release"))
    public static let dev: Self = .debug(name: .dev, xcconfig: .xcconfigPath(SchemeMode.dev.schemeName))
    public static let stage: Self = .debug(name: .stage, xcconfig: .xcconfigPath(SchemeMode.stage.schemeName))
    public static let live: Self = .release(name: .live, xcconfig: .xcconfigPath(SchemeMode.live.schemeName))
}
