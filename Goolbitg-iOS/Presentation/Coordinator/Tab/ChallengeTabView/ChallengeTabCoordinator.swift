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
    case challengeAdd(ChallengeAddViewFeature)
    case challengeDetail(ChallengeDetailFeature)
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
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.moveToChallengeAdd)))):
                
                state.routes.push(.challengeAdd(ChallengeAddViewFeature.State( dismissButtonHidden: false)))
                return .send(.delegate(.tabbarHidden))
                
            case .router(.routeAction(id: .challengeAdd, action: .challengeAdd(.delegate(.dismissTapped)))):
                state.routes.pop()
                return .send(.delegate(.showTabbar))
                
            case .router(.routeAction(id: .challengeAdd, action: .challengeAdd(.delegate(.successAdd)))):
                
                state.routes.pop()
                
                return .run { send in
                    await send(.delegate(.showTabbar))
                    await send(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadData)))))
                }
                
                /// 챌린지 디테일
            case let .router(.routeAction(id: .home, action: .home(.delegate(.moveToDetail(itemID))))):
                
                state.routes.push(.challengeDetail(ChallengeDetailFeature.State(challengeID: itemID)))
                
                return .run { send in
                    await send(.delegate(.tabbarHidden))
                }
                
            case .router(.routeAction(id: .challengeDetail, action: .challengeDetail(.delegate(.dismissTap)))):
                
                state.routes.popToRoot()
                
                return .run { send in
                    await send(.delegate(.showTabbar))
                    await send(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadData)))))
                }
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
