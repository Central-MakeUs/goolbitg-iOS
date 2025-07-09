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
    case groupChallengeCreate(GroupChallengeCreateViewFeature)
    case groupChallengeDetail(ChallengeGroupDetailViewFeature)
    case groupChallengeSetting(ChallengeGroupSettingViewFeature)
    case groupChallengeModify(GroupChallengeCreateViewFeature)
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
        Reduce {
            state,
            action in
            switch action {
            case .router(.routeAction(id: .home, action: .home(.delegate(.moveToGroupChallengeCreate)))):
                
                state.routes.presentCover(
                    .groupChallengeCreate(
                        GroupChallengeCreateViewFeature.State()
                    )
                )
            case let .router(.routeAction(id: .home, action: .home(.delegate(.moveToGroupChallengeDetail(groupID))))):
                state.routes.presentCover(
                    .groupChallengeDetail(
                        ChallengeGroupDetailViewFeature.State(groupID: groupID)
                    ),
                    embedInNavigationView: true
                )
                // MARK: GroupChallenge
            case .router(.routeAction(id: .groupChallengeCreate, action: .groupChallengeCreate(.delegate(.dismiss)))):
                
                state.routes.dismiss()
                return .send(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadGroupData)))))
                
            case .router(.routeAction(id: .groupChallengeCreate, action: .groupChallengeCreate(.delegate(.createSuccess)))):
                
                state.routes.dismiss()
                return .send(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadGroupData)))))
                
                // MARK: GroupChallengeDetail
            case .router(.routeAction(id: .groupChallengeDetail, action: .groupChallengeDetail(.delegate(.back)))):
                state.routes.dismiss()
                
            case let .router(.routeAction(id: .groupChallengeDetail, action: .groupChallengeDetail(.delegate(.goSettingView(ifOwner, roomID))))):
                
                state.routes.push(.groupChallengeSetting(ChallengeGroupSettingViewFeature.State(ifOwner: ifOwner, roomID: roomID)))
                
                
                
                // MARK: GroupChallengeSetting
            case .router(.routeAction(id: .groupChallengeSetting, action: .groupChallengeSetting(.delegate(.removeSuccess)))):
                state.routes.dismiss()
                
                return .send(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadGroupData)))))
                
            case .router(.routeAction(id: .groupChallengeSetting, action: .groupChallengeSetting(.delegate(.back)))):
                state.routes.pop()
                
            case let .router(.routeAction(id: .groupChallengeSetting, action: .groupChallengeSetting(.delegate(.modifyTapped(groupID))))):
                state.routes
                    .push(
                        .groupChallengeModify(
                            GroupChallengeCreateViewFeature.State(
                                mode: .modify,
                                ifModifyRoomID: groupID
                            )
                        )
                    )
                
            case .router(.routeAction(id: .groupChallengeModify, action: .groupChallengeModify(.delegate(.dismiss)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .groupChallengeModify, action: .groupChallengeModify(.delegate(.modifySuccess)))):
                state.routes.dismiss()
                
                return .send(.router(.routeAction(id: .home, action: .home(.parentEvent(.reloadGroupData)))))
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
