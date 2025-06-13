//
//  Cores.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/20/25.
//

import ProjectDescription

// MARK: Domain
public enum DomainConfig {
    public static let frameworkName: String = "Domain"
    public static let path: Path = .relativeToRoot("Projects/Domain")
    
    public static let target: TargetDependency = .project(
        target: frameworkName,
        path: path
    )
}
public extension TargetDependency {
    static let domain: Self = DomainConfig.target
}

// MARK: System
public extension TargetDependency {
    static let swiftyBeaver: Self = .external(name: "SwiftyBeaver", condition: nil)
}

// MARK: TCA
public extension TargetDependency {
//    static let tca: Self = .package(product: "ComposableArchitecture", type: .runtime, condition: nil)
    static let tca: Self = .external(name: "ComposableArchitecture", condition: nil)
    static let tcaCoordinator: Self = .external(name: "TCACoordinators", condition: nil)
}

// MARK: FireBase
public extension TargetDependency {
    static let firebaseCore: Self = .external(name: "FirebaseCore")
    static let firebaseMessaging: Self = .external(name: "FirebaseMessaging")
    static let fireBaseAnalytics: Self = .external(name: "FirebaseAnalytics", condition: nil)
}

// MARK: KAKAO
public extension TargetDependency {
    static let kakaoSDKCommon: Self = .external(name: "KakaoSDKCommon", condition: nil)
    static let kakaoSDKAuth: Self = .external(name: "KakaoSDKAuth", condition: nil)
//    static let kakaoSDK: Self = .sdk(name: "KakaoOpenSDK", type: .library, status: .required, condition: .none)
    static let kakaoSDK: Self = .external(name: "KakaoSDK", condition: nil)
}

// MARK: Network
public extension TargetDependency {
    static let kingfisher: Self = .external(name: "Kingfisher", condition: nil)
    static let alamofire: Self = .external(name: "Alamofire", condition: nil)
//    static let jwtToken: Self = .external(name: "SwiftJWT", condition: nil)
}

// MARK: UI
public extension TargetDependency {
    static let popupView: Self = .external(name: "PopupView", condition: nil)
    static let swiftyGif: Self = .external(name: "SwiftyGif", condition: nil)
    static let lottie: Self = .external(name: "Lottie", condition: nil)
}
