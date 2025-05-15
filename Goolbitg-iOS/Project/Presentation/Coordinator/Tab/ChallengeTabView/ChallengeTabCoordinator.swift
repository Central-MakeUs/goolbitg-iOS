//
//  ChallengeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum ChallengeTabScreen {
    case home(ChallengeTabFeature)
//    case challengeAdd(ChallengeAddViewFeature)
//    case challengeDetail(ChallengeDetailFeature)
}

@Reducer
struct ChallengeTabCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        static let initialState = State(routes: [.root(.home(ChallengeTabFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<ChallengeTabScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ChallengeTabScreen>)
        case delegate(Delegate)
        
        enum Delegate {
            case tabbarHidden
            case showTabbar
        }
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeTabCoordinator {
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
