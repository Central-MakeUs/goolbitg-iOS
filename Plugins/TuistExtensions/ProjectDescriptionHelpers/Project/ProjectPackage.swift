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
    "SwiftyBeaver": .framework, // 제거 예상
    "KakaoSDK": .framework,
    "Lottie": .framework,
    "Kingfisher" : .framework,
    "PopupView" : .framework
]

private let tcaDynamics: [String : Product] = [
    "ComposableArchitecture": productType(),
    "TCACoordinators" : productType(),
    "CasePaths": .framework,
    "FlowStacks": .framework,
    "IssueReporting": .framework,
    "XCTestDynamicOverlay": .framework,
//    "DependenciesMacros": .macro,
    "Dependencies": .framework,
    "CombineSchedulers": .framework,
    "ConcurrencyExtras": .framework,
    "SwiftNavigation": .framework,
//    "SwiftUINavigation": .framework,
//    "UIKitNavigation": .framework,
//    "UIKitNavigationShim": .framework,
    "CustomDump": .framework,
    "OrderedCollections": .framework,
    "PerceptionCore": .framework,
//    "CasePathsMacros" : .macro,
    "Perception": .framework,
    "Sharing": .framework,
    "IdentifiedCollections": .framework,
    "SwiftUIIntrospect" : .framework,
    "Clocks": .framework,
    "_CollectionsUtilities": .framework,
]

func productType() -> Product {
    if case let .string(linking) = Environment.linking {
        print("static: framework")
        return linking == "static" ? .staticFramework : .framework
    } else {
        print("make: framework")
        return .framework
    }
}



 
