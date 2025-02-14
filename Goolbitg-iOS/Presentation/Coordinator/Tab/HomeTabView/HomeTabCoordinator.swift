//
//  HomeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum homeTabScreen {
    case home(GBHomeTabViewFeature)
//    case challengeDetail(ChallengeDetailFeature)
}

@Reducer
struct HomeTabCoordinator {
    
    @ObservableState
    struct State: Equatable {
        
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
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
