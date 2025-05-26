//
//  AppConfig.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/18/25.
//

import ProjectDescription

public enum AppConfig {
    
    public static let appName = "Goolbitg-iOS-tuist" // 임시 트위스트 접두어
    
    public static let noTuistAppName = "Goolbitg-iOS" // 임시 트위스트 접두어 없는버전 후에 위로 옮겨야함
    
    public static let productName: String = "굴비잇기"
    
    public static let bundleID: String = "com.Goolbitg-iOS"
    
    public static let deployTarget: DeploymentTargets = .iOS("16.0")
    
    public static let destinations: Destinations = [.iPhone]
    
    public static let appPath: Path = .relativeToRoot("Projects/App")
}
