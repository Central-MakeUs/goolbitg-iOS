//
//  TabNavigationCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import Foundation
import ComposableArchitecture
import FeatureCommon
import FeatureBuyOrNot
import Data
import Utils
import FeatureMyPage
import FeatureChallenge

@Reducer
public struct TabNavigationCoordinator {
    
    public init() {}

    @Dependency(\.chatRepository) var chatRepository

    @ObservableState
    public struct State: Equatable {
        public static let initialState = State()

        var tabView = GBTabBarCoordinator.State()
        var path = StackState<Path.State>()
        var suppressNextChatPathRemovalDisconnect = false
    }

    @Reducer(state: .equatable)
    public enum Path {
        case chatView(ChattingViewFeature)
        case buyOrNotAdd(BuyOrNotAddViewFeature)
        case challengeAdd(ChallengeAddViewFeature)
        case challengeDetail(ChallengeDetailFeature)
        case pushHabitChart(HabitChartsFeature)
        case groupChallengeDetail(ChallengeGroupDetailViewFeature)
        case groupChallengeSetting(ChallengeGroupSettingViewFeature)
        case groupChallengeModify(GroupChallengeCreateViewFeature)
    }
    
    public enum Action {
        case tabView(GBTabBarCoordinator.Action)
        case path(StackActionOf<Path>)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.tabView, action: \.tabView) {
            GBTabBarCoordinator()
        }
        core
            .forEach(\.path, action: \.path)
            .onChange(of: \.path) { oldValue, newValue in
                navCore(oldValue: oldValue, newValue: newValue)
            }
    }
}

extension TabNavigationCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabView(.homeTabAction(.delegate(.moveToChallengeDetail(itemID)))):
                state.path.append(.challengeDetail(ChallengeDetailFeature.State(challengeID: itemID)))

            case .tabView(.buyOrNotTabAction(.delegate(.moveToAddView))):
                state.path.append(.buyOrNotAdd(BuyOrNotAddViewFeature.State(stateMode: .add)))

            case let .tabView(.buyOrNotTabAction(.delegate(.moveToModifierView(model, idx)))):
                state.path.append(.buyOrNotAdd(BuyOrNotAddViewFeature.State(stateMode: .modifier(model, idx: idx))))

            case let .tabView(.buyOrNotTabAction(.delegate(.moveToChatView(userID, userName: userName, model)))):
                state.suppressNextChatPathRemovalDisconnect = false
                state.path.append(.chatView(ChattingViewFeature.State(
                    userName: userName,
                    userID: userID,
                    model: model,
                    sessionLease: UUID()
                )))

            case .tabView(.challengeTabAction(.delegate(.moveToChallengeAdd))):
                state.path.append(.challengeAdd(ChallengeAddViewFeature.State(dismissButtonHidden: false)))

            case let .tabView(.challengeTabAction(.delegate(.moveToChallengeDetail(itemID)))):
                state.path.append(.challengeDetail(ChallengeDetailFeature.State(challengeID: itemID)))

            case let .tabView(.challengeTabAction(.delegate(.moveToGroupChallengeDetail(groupID)))):
                state.path.append(.groupChallengeDetail(ChallengeGroupDetailViewFeature.State(groupID: groupID)))

            case .tabView(.myPageTabAction(.delegate(.moveToHabitChart))):
                state.path.append(.pushHabitChart(HabitChartsFeature.State()))

            case let .path(.element(id: _, action: .chatView(.delegate(.moveToModifierView(model))))):
                state.path.append(.buyOrNotAdd(BuyOrNotAddViewFeature.State(stateMode: .modifierFromChat(model))))

            case .path(.element(id: _, action: .challengeDetail(.delegate(.dismissTap)))):
                state.path.removeLast()
                return .send(.tabView(.challengeTabAction(.home(.parentEvent(.reloadData)))))

            case .path(.element(id: _, action: .chatView(.delegate(.backTapped)))):
                let sessionLease = chatSessionLease(in: state.path)
                state.suppressNextChatPathRemovalDisconnect = true
                state.path.removeLast()
                let repo = chatRepository
                Logger.debug("Coordinator chat teardown - explicit back")
                return .run { _ in
                    guard let sessionLease else { return }
                    await repo.disconnectSocket(lease: sessionLease)
                }

            case .path(.element(id: _, action: .buyOrNotAdd(.delegate(.dismiss)))):
                state.path.removeLast()

            case .path(.element(id: _, action: .buyOrNotAdd(.delegate(.succressItem)))):
                state.path.removeLast()
                return .send(.tabView(.buyOrNotTabAction(.delegate(.newBuyOrNotItem))))

            case let .path(.element(id: _, action: .buyOrNotAdd(.delegate(.successModifer(model, idx))))):
                state.path.removeLast()
                return .send(.tabView(.buyOrNotTabAction(.delegate(.modifierSuccess(model, idx: idx)))))

            case let .path(.element(id: _, action: .buyOrNotAdd(.delegate(.successModifierFromChat(model))))):
                state.path.removeLast()
                guard let lastID = state.path.ids.last else { return .none }
                return .send(.path(.element(id: lastID, action: .chatView(.featureEvent(.productUpdated(model))))))

            case .path(.element(id: _, action: .challengeAdd(.delegate(.dismissTapped)))):
                state.path.removeLast()

            case .path(.element(id: _, action: .challengeAdd(.delegate(.successAdd)))):
                state.path.removeLast()
                return .send(.tabView(.challengeTabAction(.home(.parentEvent(.reloadData)))))

            case .path(.element(id: _, action: .groupChallengeDetail(.delegate(.back)))):
                state.path.removeLast()

            case let .path(.element(id: _, action: .groupChallengeDetail(.delegate(.goSettingView(ifOwner, roomID))))):
                state.path.append(.groupChallengeSetting(ChallengeGroupSettingViewFeature.State(ifOwner: ifOwner, roomID: roomID)))

            case .path(.element(id: _, action: .groupChallengeSetting(.delegate(.back)))):
                state.path.removeLast()

            case let .path(.element(id: _, action: .groupChallengeSetting(.delegate(.modifyTapped(groupID))))):
                state.path.append(
                    .groupChallengeModify(
                        GroupChallengeCreateViewFeature.State(
                            mode: .modify,
                            ifModifyRoomID: groupID
                        )
                    )
                )

            case .path(.element(id: _, action: .groupChallengeSetting(.delegate(.removeSuccess)))):
                popGroupChallengeFlow(&state.path)
                return .send(.tabView(.challengeTabAction(.home(.parentEvent(.reloadGroupData)))))

            case .path(.element(id: _, action: .groupChallengeSetting(.delegate(.exitSuccess)))):
                popGroupChallengeFlow(&state.path)
                return .send(.tabView(.challengeTabAction(.home(.parentEvent(.reloadGroupData)))))

            case .path(.element(id: _, action: .groupChallengeModify(.delegate(.dismiss)))):
                state.path.removeLast()

            case .path(.element(id: _, action: .groupChallengeModify(.delegate(.modifySuccess)))):
                popGroupChallengeFlow(&state.path)
                return .send(.tabView(.challengeTabAction(.home(.parentEvent(.reloadGroupData)))))

            default:
                break
            }
            return .none
        }
    }

    private func navCore(
        oldValue: StackState<Path.State>,
        newValue: StackState<Path.State>
    ) -> some ReducerOf<Self> {
        Reduce { state, _ in
            state.tabView.tabbarHidden = !newValue.isEmpty

            let hadChatPath = hasChatPath(in: oldValue)
            let hasChatPath = hasChatPath(in: newValue)

            guard hadChatPath, !hasChatPath else {
                return .none
            }

            if state.suppressNextChatPathRemovalDisconnect {
                state.suppressNextChatPathRemovalDisconnect = false
                return .none
            }

            guard let removedLease = removedChatSessionLease(oldValue: oldValue, newValue: newValue) else {
                return .none
            }

            let repo = chatRepository
            Logger.debug("Coordinator chat teardown - path removal fallback")
            return .run { _ in
                await repo.disconnectSocket(lease: removedLease)
            }
        }
    }

    private func hasChatPath(
        in path: StackState<Path.State>
    ) -> Bool {
        path.contains { element in
            if case .chatView = element {
                return true
            }
            return false
        }
    }

    private func chatSessionLease(
        in path: StackState<Path.State>
    ) -> UUID? {
        for element in path.reversed() {
            if case let .chatView(chatState) = element {
                return chatState.sessionLease
            }
        }
        return nil
    }

    private func removedChatSessionLease(
        oldValue: StackState<Path.State>,
        newValue: StackState<Path.State>
    ) -> UUID? {
        let activeLeases = Set(newValue.compactMap { element -> UUID? in
            if case let .chatView(chatState) = element {
                return chatState.sessionLease
            }
            return nil
        })

        for element in oldValue.reversed() {
            if case let .chatView(chatState) = element,
               !activeLeases.contains(chatState.sessionLease) {
                return chatState.sessionLease
            }
        }

        return nil
    }

    private func popGroupChallengeFlow(_ path: inout StackState<Path.State>) {
        while let last = path.last {
            switch last {
            case .groupChallengeModify, .groupChallengeSetting, .groupChallengeDetail:
                path.removeLast()
            default:
                return
            }
        }
    }
}
