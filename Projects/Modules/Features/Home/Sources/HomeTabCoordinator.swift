//
//  HomeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture
import FeatureCommon

@Reducer
public struct HomeTabCoordinator {
    public init() {}
    @ObservableState
    public struct State: Equatable {
        
        public static let initialState = State()

        var home = GBHomeTabViewFeature.State()
        var pushList: PushListViewFeature.State?
    }
    
    public enum Action {
        case home(GBHomeTabViewFeature.Action)
        case pushList(PushListViewFeature.Action)
        case delegate(Delegate)
        public enum Delegate {
            case hiddenTabbar
            case showTabbar
            case reloadChallengeData
            case moveToChallengeDetail(String)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            GBHomeTabViewFeature()
        }
        core
    }
}

extension HomeTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .home(.delegate(.moveToDetail(itemID))):
                return .send(.delegate(.moveToChallengeDetail(itemID)))

            /// 푸시알림 이동
            case .home(.delegate(.moveToPushListView)):
                state.pushList = PushListViewFeature.State()

            case .pushList(.delegate(.dismiss)):
                state.pushList = nil
                 
            default:
                break
            }
            return .none
        }
        .ifLet(\.pushList, action: \.pushList) {
            PushListViewFeature()
        }
    }
}
