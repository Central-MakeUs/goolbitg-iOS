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
import Data
import Utils

@Reducer(state: .hashable)
public enum TabNavigationScreen {
    case tabView(GBTabBarCoordinator)
    case challengeDetail(ChallengeDetailFeature)
    case challengeAdd(ChallengeAddViewFeature)
    case chatView(ChattingViewFeature)
}


@Reducer
public struct TabNavigationCoordinator {
    
    public init() {}

    @Dependency(\.chatRepository) var chatRepository
    
    @ObservableState
    public struct State: Equatable, Sendable, Hashable {
        public static let initialState = State(routes: [.root(.tabView(GBTabBarCoordinator.State()), embedInNavigationView: true)])
        public var routes: IdentifiedArrayOf<Route<TabNavigationScreen.State>>
        var suppressNextChatRouteRemovalDisconnect: Bool = false
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

                /// BuyOrNot Tab - 채팅 이동
            case let .router(.routeAction(id: .tabView, action: .tabView(.buyOrNotTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.moveToChatView(userID, userName, model))))))))):

                state.suppressNextChatRouteRemovalDisconnect = false
                state.routes.push(.chatView(ChattingViewFeature.State(
                    userName: userName,
                    userID: userID,
                    model: model,
                    sessionLease: UUID()
                )))

            case .router(.routeAction(id: .chatView, action: .chatView(.delegate(.backTapped)))):
                let sessionLease = chatSessionLease(in: state.routes)
                state.suppressNextChatRouteRemovalDisconnect = true
                state.routes.pop()
                let repo = chatRepository
                Logger.debug("Coordinator chat teardown - explicit back")
                return .run { _ in
                    guard let sessionLease else { return }
                    await repo.disconnectSocket(lease: sessionLease)
                }

            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
        .onChange(of: \.routes) { oldValue, newValue in
            navCore(oldValue: oldValue, newValue: newValue)
        }
    }
    
    private func navCore(
        oldValue: IdentifiedArrayOf<Route<TabNavigationScreen.State>>,
        newValue: IdentifiedArrayOf<Route<TabNavigationScreen.State>>
    ) -> some ReducerOf<Self> {
        Reduce { state, _ in
            let hadChatRoute = hasChatRoute(in: oldValue)
            let hasChatRoute = hasChatRoute(in: newValue)

            guard hadChatRoute, !hasChatRoute else {
                return .none
            }

            if state.suppressNextChatRouteRemovalDisconnect {
                state.suppressNextChatRouteRemovalDisconnect = false
                return .none
            }

            guard let removedLease = removedChatSessionLease(oldValue: oldValue, newValue: newValue) else {
                return .none
            }

            let repo = chatRepository
            Logger.debug("Coordinator chat teardown - route removal fallback")
            return .run { _ in
                await repo.disconnectSocket(lease: removedLease)
            }
        }
    }

    private func hasChatRoute(
        in routes: IdentifiedArrayOf<Route<TabNavigationScreen.State>>
    ) -> Bool {
        routes.contains { route in
            if case .chatView = route.screen {
                return true
            }
            return false
        }
    }

    private func chatSessionLease(
        in routes: IdentifiedArrayOf<Route<TabNavigationScreen.State>>
    ) -> UUID? {
        for route in routes.reversed() {
            if case let .chatView(chatState) = route.screen {
                return chatState.sessionLease
            }
        }
        return nil
    }

    private func removedChatSessionLease(
        oldValue: IdentifiedArrayOf<Route<TabNavigationScreen.State>>,
        newValue: IdentifiedArrayOf<Route<TabNavigationScreen.State>>
    ) -> UUID? {
        let activeLeases = Set(newValue.compactMap { route -> UUID? in
            if case let .chatView(chatState) = route.screen {
                return chatState.sessionLease
            }
            return nil
        })

        for route in oldValue.reversed() {
            if case let .chatView(chatState) = route.screen,
               !activeLeases.contains(chatState.sessionLease) {
                return chatState.sessionLease
            }
        }

        return nil
    }
}
