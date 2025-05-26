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
public enum ChallengeTabScreen {
    case home(ChallengeTabFeature)
//    case challengeAdd(ChallengeAddViewFeature)
//    case challengeDetail(ChallengeDetailFeature)
}

@Reducer
public struct ChallengeTabCoordinator {
    public init () {}
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        public static let initialState = State(routes: [.root(.home(ChallengeTabFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<ChallengeTabScreen.State>>
    }
    
    public enum Action {
        case router(IdentifiedRouterActionOf<ChallengeTabScreen>)
        case delegate(Delegate)
        
        public enum Delegate {
            case tabbarHidden
            case showTabbar
        }
    }
    
    public var body: some ReducerOf<Self> {
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
