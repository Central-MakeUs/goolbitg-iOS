//
//  TabNavigationCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct TabNavigationCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<TabNavigationCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                    
                case let .tabView(store):
                    GBTabBarView(store: store)
                    
                case let .challengeDetail(store):
                    ChallengeDetailView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture(false)
                    
                case let .challengeAdd(store):
                    ChallengeAddView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture(false)
                }
            }
        }
    }
}


extension TabNavigationScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .tabView:
            return .tabView
        case .challengeDetail:
            return .challengeDetail
        case .challengeAdd:
            return .challengeAdd
        }
    }
    
    enum ID: Identifiable {
        case tabView
        case challengeDetail
        case challengeAdd
        
        var id: ID {
            return self
        }
    }
}
