//
//  Module.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/19/25.
//

import ProjectDescription

public enum Module {
    case feature(FeatureType)
    case Data
    case utils
    
    private var name: String {
        switch self {
        case .feature(let featureType):
            return featureType.rawValue
        case .Data:
            return "Data"
        case .utils:
            return "Utils"
        }
    }
    
    public var frameWorkName: String {
        switch self {
        case .feature(let featureType):
            return "Feature\(name)"
        case .Data, .utils:
            return name
        }
        
    }
    
    public var path: Path {
        switch self {
        case .feature(let featureType):
            let path = featureType.leadingPath + self.name
            return .relativeToRoot(path)
        case .Data, .utils:
            let path = "Projects/Modules/\(name)"
            return .relativeToRoot(path)
        }
    }
    
    /// Feature 전용
    public static var features: [Module] {
        return FeatureType.allCases.map { .feature($0) }
    }
    
    
    public var projectTarget: TargetDependency {
        switch self {
        case .feature:
            return .project(
                target: "Feature\(name)",
                path: path
            )
        case .Data, .utils:
            return .project(
                target: name,
                path: path
            )
        }
    }
    
    public static var modules: [Module] {
        return features + [.Data, .utils]
    }
    
    public static var tabNeedModules: [Module] {
        
        return FeatureType.allCases
            .filter { $0 != .Intro && $0 != .Tab }
            .map { .feature($0) }
    }
}
