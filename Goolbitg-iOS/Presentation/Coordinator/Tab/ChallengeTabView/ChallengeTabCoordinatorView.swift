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
        }
    }
    
    enum ID: Identifiable {
        case home
        
        var id: ID {
            return self
        }
    }
}
