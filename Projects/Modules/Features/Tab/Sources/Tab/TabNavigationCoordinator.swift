//
//  TabNavigationCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators
import FeatureCommon

@Reducer(state: .equatable)
public enum TabNavigationScreen {
    case tabView(GBTabBarCoordinator)
    case challengeDetail(ChallengeDetailFeature)
    case challengeAdd(ChallengeAddViewFeature)
}


@Reducer
public struct TabNavigationCoordinator {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public static let initialState = State(routes: [.root(.tabView(GBTabBarCoordinator.State()), embedInNavigationView: true)])
        public var routes: IdentifiedArrayOf<Route<TabNavigationScreen.State>>
    }
    
    public enum Action {
        case router(IdentifiedRouterActionOf<TabNavigationScreen>)
    }
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension TabNavigationCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
                /// HOME Tab
            case let .router(.routeAction(id: .tabView, action: .tabView(.homeTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.moveToDetail(itemID))))))))):
                
                state.routes.push(.challengeDetail(ChallengeDetailFeature.State(challengeID: itemID)))
                
            case .router(.routeAction(id: .challengeDetail, action: .challengeDetail(.delegate(.dismissTap)))):
                state.routes.popToRoot()
                
                return .run { send in
                    await send(.router(.routeAction(id: .tabView, action: .tabView(.challengeTabAction(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadData)))))))))
                }
                
                /// Challenge Tab
            case .router(.routeAction(id: .tabView, action: .tabView(.challengeTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.moveToChallengeAdd)))))))):
                
                state.routes.push(.challengeAdd(ChallengeAddViewFeature.State(dismissButtonHidden: false)))
                
            case .router(.routeAction(id: .challengeAdd, action: .challengeAdd(.delegate(.dismissTapped)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .challengeAdd, action: .challengeAdd(.delegate(.successAdd)))):
                state.routes.pop()
                return .run { send in
                    await send(.router(.routeAction(id: .tabView, action: .tabView(.challengeTabAction(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadData)))))))))
                }
            case let .router(.routeAction(id: .tabView, action: .tabView(.challengeTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.moveToDetail(itemID))))))))):
                
                state.routes.push(.challengeDetail(ChallengeDetailFeature.State(challengeID: itemID)))
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
