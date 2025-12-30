//
//  ProjectPackage.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 6/13/25.
//

import Foundation
import ProjectDescription

public var getProjectPackageSetting: [String: Product] {
    let result = projectProductTypes.merging(tcaDynamics) { current, _ in
        return current
    }
    return result
}

private let projectProductTypes: [String: Product] = [
    "Alamofire": .framework, // 제거 예상
    "TCACoordinators" : .framework,
    "SwiftyBeaver": .framework, // 제거 예상
    "KakaoSDK": .framework,
    "Lottie": .framework,
    "Kingfisher" : .framework,
    "PopupView" : .framework
]

private let tcaDynamics: [String : Product] = [
    "ComposableArchitecture": .framework,
    "Dependencies": .framework,
    "CombineSchedulers": .framework,
    "Sharing": .framework,
    "SwiftUINavigation": .framework,
    "UIKitNavigation": .framework,
    "UIKitNavigationShim": .framework,
    "ConcurrencyExtras": .framework,
    "Clocks": .framework,
    "CustomDump": .framework,
    "IdentifiedCollections": .framework,
    "XCTestDynamicOverlay": .framework,
    "IssueReporting": .framework,
    "_CollectionsUtilities": .framework,
    "PerceptionCore": .framework,
    "Perception": .framework,
    "OrderedCollections": .framework,
    "CasePaths": .framework,
    "DependenciesMacros": .framework,
    "FlowStacks": .framework
]

