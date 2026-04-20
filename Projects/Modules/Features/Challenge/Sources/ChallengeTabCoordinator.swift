//
//  ChallengeTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import Foundation
import ComposableArchitecture
import FeatureCommon

@Reducer
public struct ChallengeTabCoordinator {
    public init () {}

    @ObservableState
    public struct State: Equatable {
        public static let initialState = State()

        var home = ChallengeTabFeature.State()
        var groupChallengeCreate: GroupChallengeCreateViewFeature.State?
        var groupChallengeSearch: ChallengeGroupSearchViewFeature.State?
    }

    public enum Action {
        case home(ChallengeTabFeature.Action)
        case groupChallengeCreate(GroupChallengeCreateViewFeature.Action)
        case groupChallengeSearch(ChallengeGroupSearchViewFeature.Action)
        case delegate(Delegate)

        public enum Delegate {
            case tabbarHidden
            case showTabbar
            case moveToChallengeAdd
            case moveToChallengeDetail(String)
            case moveToGroupChallengeDetail(String)
        }
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            ChallengeTabFeature()
        }
        core
            .ifLet(\.groupChallengeCreate, action: \.groupChallengeCreate) {
                GroupChallengeCreateViewFeature()
            }
            .ifLet(\.groupChallengeSearch, action: \.groupChallengeSearch) {
                ChallengeGroupSearchViewFeature()
            }
    }
}

extension ChallengeTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .home(.delegate(.moveToChallengeAdd)):
                return .send(.delegate(.moveToChallengeAdd))

            case let .home(.delegate(.moveToDetail(itemID))):
                return .send(.delegate(.moveToChallengeDetail(itemID)))

            case .home(.delegate(.moveToGroupChallengeCreate)):
                state.groupChallengeCreate = GroupChallengeCreateViewFeature.State()

            case .home(.delegate(.moveToGroupChallengeSearchView)):
                state.groupChallengeSearch = ChallengeGroupSearchViewFeature.State()

            case let .home(.delegate(.moveToGroupChallengeDetail(groupID))):
                return .send(.delegate(.moveToGroupChallengeDetail(groupID)))

            case .groupChallengeCreate(.delegate(.dismiss)):
                state.groupChallengeCreate = nil
                return .send(.home(.parentEvent(.reloadGroupData)))

            case .groupChallengeCreate(.delegate(.createSuccess)):
                state.groupChallengeCreate = nil
                return .send(.home(.parentEvent(.reloadGroupData)))

            case .groupChallengeSearch(.delegate(.backButtonTapped)):
                state.groupChallengeSearch = nil

            case .groupChallengeSearch(.delegate(.backAndReload)):
                state.groupChallengeSearch = nil
                return .send(.home(.parentEvent(.reloadGroupData)))

            default:
                break
            }
            return .none
        }
    }
}
