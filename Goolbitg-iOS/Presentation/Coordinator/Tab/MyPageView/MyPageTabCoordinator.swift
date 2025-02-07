//
//  MyPageTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case home(MyPageViewFeature)
    case revokePage(RevokeFeature)
}

@Reducer
struct MyPageTabCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.home(MyPageViewFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<MyPageScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MyPageScreen>)
        case delegate(Delegate)
        
        enum Delegate {
            case tabViewHidden
            case tabViewShow
        }
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension MyPageTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: .home, action: .home(.delegate(.revokedEvent)))):
                state.routes.push(.revokePage(RevokeFeature.State()))
                return .send(.delegate(.tabViewHidden))
            
            case .router(.routeAction(id: .revokePage, action: .revokePage(.delegate(.dismiss)))):
                state.routes.pop()
                return .send(.delegate(.tabViewShow))
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
