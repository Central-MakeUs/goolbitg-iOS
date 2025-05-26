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
//    case live
    
    public var schemeName: String {
        switch self {
        case .dev:
            return "DEV"
//        case .live:
//            return "LIVE"
        case .stage:
            return "STAGE"
        }
    }
    
    public var runActionConfiguration: ConfigurationName {
        switch self {
        case .dev:
            return .debug
//        case .live:
//            return .release
        case .stage:
            return .debug
        }
    }
    
    public func getName() -> String {
        return schemeName
    }
    
    public static func getSelf(schemeString: String) -> SchemeMode? {
        return SchemeMode.allCases.first { $0.schemeName == schemeString }
    }
    
    public var fullScheme: String {
        return AppConfig.appName + "-info-" + self.schemeName
    }
    
    public static func getSchemes(targetName: String, path: Path) -> [Scheme] {
        let all = Self.allCases
        let mapping = all.map { mode -> Scheme in
            print(mode.runActionConfiguration)
            return Scheme.scheme(
                name: mode.schemeName,
                shared: true,
                hidden: false,
                buildAction: .buildAction(
                    targets: [
                        .project(path: path, target: targetName)
                    ],
                    findImplicitDependencies: true
                ),
                testAction: nil,
                runAction: .runAction(configuration: mode.runActionConfiguration),
                archiveAction: .archiveAction(configuration: mode.runActionConfiguration),
                profileAction: .profileAction(configuration: mode.runActionConfiguration),
                analyzeAction: .analyzeAction(configuration: mode.runActionConfiguration)
            )
        }
        
        return mapping
    }
}

extension Path {
    
    public static func plistName(schemeMode: SchemeMode) -> Path {
        return .relativeToRoot("AppSettingFiles/\(schemeMode.fullScheme).Plist")
    }
    
    public static func onesPlistName() -> Path {
        return .relativeToRoot("AppSettingFiles/InfoPlist/Info.Plist")
    }
    
    public static func xcconfigPath(_ xcconfigName: String) -> Path {
        .relativeToRoot("AppSettingFiles/XCConfigs/\(xcconfigName).xcconfig")
    }

}
