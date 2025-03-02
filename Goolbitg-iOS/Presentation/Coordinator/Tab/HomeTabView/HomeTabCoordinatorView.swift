//
//  HomeTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct HomeTabCoordinatorView: View {
    @Perception.Bindable var store: StoreOf<HomeTabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension HomeTabCoordinatorView {
    private var content: some View {
        VStack(spacing:0) {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .home(store):
                    GBHomeTabViewV1(store: store)
                        .disableBackGesture(false)
                    
//                case let .challengeDetail(store):
//                    ChallengeDetailView(store: store)
//                        .navigationBarBackButtonHidden()
//                        .disableBackGesture(false)
                    
                case let .pushList(store):
                    PushListView(store:store)
                    
                }
            }
        }
    }
}

extension homeTabScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .home:
            return .home
            
        case .pushList:
            return .pushList
        }
    }
    
    enum ID: Identifiable {
        case home
        case pushList
        
        var id: ID {
            return self
        }
    }
}
