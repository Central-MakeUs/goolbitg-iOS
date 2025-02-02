//
//  ChallengeTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct ChallengeTabCoordinatorView: View {
    @Perception.Bindable var store: StoreOf<ChallengeTabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension ChallengeTabCoordinatorView {
    private var content: some View {
        VStack(spacing:0) {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .home(store):
                    ChallengeTabView(store: store)
                        .disableBackGesture(false)
                    
                case let .challengeAdd(store):
                    ChallengeAddView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture(false)
                    
                case let .challengeDetail(store):
                    ChallengeDetailView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture(false)
                }
            }
        }
    }
}

extension ChallengeTabScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .home:
            return .home
        case .challengeAdd:
            return .challengeAdd
        case .challengeDetail:
            return .challengeDetail
        }
    }
    
    enum ID: Identifiable {
        case home
        case challengeAdd
        case challengeDetail
        
        var id: ID {
            return self
        }
    }
}
