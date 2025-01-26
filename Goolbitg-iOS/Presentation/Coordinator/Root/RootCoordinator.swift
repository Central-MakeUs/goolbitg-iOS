//
//  RootCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators


@Reducer
struct RootCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        var currentView: ChangeRootView = .splashLogin
        
        var splashLogin = SplashLoginCoordinator.State.initialState
    }
    
    enum Action {
        case splashLoginAction(SplashLoginCoordinator.Action)
        
        case changeView(ChangeRootView)
        case deepLink(DeepLinkCase)
    }
    
    enum ChangeRootView {
        case splashLogin
        case mainTab
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.splashLogin, action: \.splashLoginAction) {
            SplashLoginCoordinator()
        }
        
        core
    }
}

extension RootCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
//            case let .splashLoginAction(.sendDeepLink(deepLinkURL)):
//                guard let deepLinkCase = DeepLinkCase(urlString: deepLinkURL) else {
//                    Logger.error("DeepLink Fail")
//                    return .none
//                }
//                deepLinkAction(deepLinkCase, state: &state)
            default:
                break
            }
            return .none
        }
    }
}

extension RootCoordinator {
    private func deepLinkAction(_ deepLink: DeepLinkCase, state: inout State) {
        switch deepLink {
        case .userInfo:
            state.splashLogin.routes.push(.userInfoRequestView(AuthRequestFeature.State()))
        }
    }
}
