//
//  GBTabBarCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import Foundation
import ComposableArchitecture

/*
 1. 로딩 뷰 시급함
 2. 블러 뷰 쪽 컨펌
 3. 시작 값 max 값
 */

enum TabCase: Hashable, CaseIterable {
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
struct GBTabBarCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var currentTab: TabCase = .homeTab
        
        var homeTabState = HomeTabCoordinator.State.initialState
        var chalengeTabState = ChallengeTabCoordinator.State.initialState
        var myPageTabState = MyPageTabCoordinator.State.initialState
        
        var tabbarHidden = false
    }
    
    enum Action {
        case homeTabAction(HomeTabCoordinator.Action)
        case challengeTabAction(ChallengeTabCoordinator.Action)
        case myPageTabAction(MyPageTabCoordinator.Action)
        case delegate(Delegate)
        
        enum Delegate {
            
        }
        case currentTab(TabCase)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.homeTabState, action: \.homeTabAction) {
            HomeTabCoordinator()
        }
        Scope(state: \.chalengeTabState, action: \.challengeTabAction) {
            ChallengeTabCoordinator()
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
            
            default:
                break
            }
            return .none
        }
    }
}
