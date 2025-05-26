//
//  TabNavigationCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import FeatureCommon

public struct TabNavigationCoordinatorView: View {
    
    public init(store: StoreOf<TabNavigationCoordinator>) {
        self.store = store
    }
    
    @Perception.Bindable var store: StoreOf<TabNavigationCoordinator>
    
    public var body: some View {
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
    public var id: ID {
        switch self {
        case .tabView:
            return .tabView
        case .challengeDetail:
            return .challengeDetail
        case .challengeAdd:
            return .challengeAdd
        }
    }
    
    public enum ID: Identifiable {
        case tabView
        case challengeDetail
        case challengeAdd
        
        public var id: ID {
            return self
        }
    }
}
