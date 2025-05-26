//
//  HomeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators
import FeatureCommon

@Reducer(state: .equatable)
public enum homeTabScreen {
    case home(GBHomeTabViewFeature)
//    case challengeDetail(ChallengeDetailFeature)
    case pushList(PushListViewFeature)
}

@Reducer
public struct HomeTabCoordinator {
    public init() {}
    @ObservableState
    public struct State: Equatable, Sendable {
        
        public static let initialState = State(routes: [.root(.home(GBHomeTabViewFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<homeTabScreen.State>>
    }
    
    public enum Action {
        case router(IdentifiedRouterActionOf<homeTabScreen>)
        case delegate(Delegate)
        public enum Delegate {
            case hiddenTabbar
            case showTabbar
        }
    }
    
    public var body: some ReducerOf<Self> {
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
