//
//  ChallengeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum ChallengeTabScreen {
    case home(ChallengeTabFeature)
}

@Reducer
struct ChallengeTabCoordinator {
    
    @ObservableState
    struct State: Equatable {
        
        static let initialState = State(routes: [.root(.home(ChallengeTabFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<ChallengeTabScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ChallengeTabScreen>)
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
