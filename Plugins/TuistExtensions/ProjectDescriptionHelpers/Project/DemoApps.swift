//
//  DemoApps.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/26/25.
//

import ProjectDescription

public enum DemoApps: String, CaseIterable {
    case home = "Home"
    case challenge = "Challenge"
    case myPage = "MyPage"
    case buyOrNot = "BuyOrNot"
    
    public static let leadingPath = "Projects/Modules/DemoApps"
    public static let moduleLeadingPath = FeatureType.leadingPathString
    
    public var appName: String {
        return "\(rawValue)App"
    }
    
    public var onlyTargetPath: Path {
        let pathString = Self.leadingPath + "/" + appName
        return .relativeToRoot(pathString)
    }
    
    public var sourceFilesList: SourceFilesList {
        let pathString = Self.moduleLeadingPath + rawValue + "/Sources/**"
        return SourceFilesList.paths([.relativeToRoot(pathString)])
    }
    
    public var bundleID : String {
        return "\(AppConfig.bundleID)-\(appName)"
    }
}
