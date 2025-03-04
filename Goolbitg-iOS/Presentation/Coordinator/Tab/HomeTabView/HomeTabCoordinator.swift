//
//  HomeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum homeTabScreen {
    case home(GBHomeTabViewFeature)
//    case challengeDetail(ChallengeDetailFeature)
    case pushList(PushListViewFeature)
}

@Reducer
struct HomeTabCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        static let initialState = State(routes: [.root(.home(GBHomeTabViewFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<homeTabScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<homeTabScreen>)
        case delegate(Delegate)
        enum Delegate {
            case hiddenTabbar
            case showTabbar
        }
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension HomeTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
                
                /// 푸시알림 이동
            case .router(.routeAction(id: .home, action: .home(.delegate(.moveToPushListView)))):
                
                state.routes.presentCover(.pushList(PushListViewFeature.State()))
                
            case .router(.routeAction(id: .pushList, action: .pushList(.delegate(.dismiss)))):
                
                state.routes.dismiss()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
