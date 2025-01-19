//
//  RootCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum RootScreen {
    case splash(SplashFeature)
    case login(LoginViewFeature)
    /// TabView로 이동준비
}

@Reducer
struct RootCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        static let initialState = State(routes: [.root(.splash(SplashFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<RootScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<RootScreen>)
        
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension RootCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: .splash, action: .splash(.delegate(.finish)))):
                
                checkLoginState(&state)
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(
            \.routes,
             action: \.router
        )
    }
}

extension RootCoordinator {
    
    /// 로그인 체크
    private func checkLoginState(_ state: inout State) {
        // MARK: 로그인 여부 확인 하고 어딜갈지 정해야함
        if UserDefaultsManager.accessToken != "" {
            
        } else {
            state.routes.push(.login(LoginViewFeature.State()))
        }
    }
}
