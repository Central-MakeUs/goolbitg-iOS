//
//  GBTabBarCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import Foundation
import ComposableArchitecture
import FeatureHome
import FeatureChallenge
import FeatureBuyOrNot
import FeatureMyPage

public enum TabCase: Hashable, CaseIterable {
    case homeTab
    /// meme -> Search Tab 변경
    case ChallengeTab
    case buyOrNotTab
    case myPageTab
    
    var title: String {
        switch self {
        case .homeTab:
            return "홈"
        case .ChallengeTab:
            return "챌린지"
        case .buyOrNotTab:
            return "살까말까"
        case .myPageTab:
            return "마이페이지"
        }
    }
}

@Reducer
public struct GBTabBarCoordinator {
    
    @ObservableState
    public struct State: Equatable {
        public static let initialState = State()
        
        var currentTab: TabCase = .homeTab
        
        var homeTabState = HomeTabCoordinator.State.initialState
        var chalengeTabState = ChallengeTabCoordinator.State.initialState
        var buyOrNotTabState = BuyOrNotTabCoordinator.State.initialState
        var myPageTabState = MyPageTabCoordinator.State.initialState
        
        var tabbarHidden = false
    }
    
    public enum Action {
        case homeTabAction(HomeTabCoordinator.Action)
        case challengeTabAction(ChallengeTabCoordinator.Action)
        case buyOrNotTabAction(BuyOrNotTabCoordinator.Action)
        case myPageTabAction(MyPageTabCoordinator.Action)
        case delegate(Delegate)
        
        public enum Delegate {
            
        }
        case currentTab(TabCase)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.homeTabState, action: \.homeTabAction) {
            HomeTabCoordinator()
        }
        Scope(state: \.chalengeTabState, action: \.challengeTabAction) {
            ChallengeTabCoordinator()
        }
        Scope(state: \.buyOrNotTabState, action: \.buyOrNotTabAction) {
            BuyOrNotTabCoordinator()
        }
        Scope(state: \.myPageTabState, action: \.myPageTabAction) {
            MyPageTabCoordinator()
        }
        core
    }
}

extension GBTabBarCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .currentTab(tabCase):
                state.currentTab = tabCase
                
            case .challengeTabAction(.delegate(.tabbarHidden)):
                state.tabbarHidden = true
            case .challengeTabAction(.delegate(.showTabbar)):
                state.tabbarHidden = false
                
            case .challengeTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.hiddenTabBar))))):
                state.tabbarHidden = true
            case .challengeTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.showTabBar))))):
                state.tabbarHidden = false
                
            case .homeTabAction(.delegate(.hiddenTabbar)):
                state.tabbarHidden = true
            case .homeTabAction(.delegate(.showTabbar)):
                state.tabbarHidden = false
                
            case .myPageTabAction(.delegate(.tabViewHidden)):
                state.tabbarHidden = true
            case .myPageTabAction(.delegate(.tabViewShow)):
                state.tabbarHidden = false
            
            default:
                break
            }
            return .none
        }
    }
}
