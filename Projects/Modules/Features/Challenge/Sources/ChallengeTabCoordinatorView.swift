//
//  ChallengeTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import Utils

public struct ChallengeTabCoordinatorView: View {
    
    public init(store: StoreOf<ChallengeTabCoordinator>) {
        self.store = store
    }
    
    @Perception.Bindable var store: StoreOf<ChallengeTabCoordinator>
    
    public var body: some View {
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
                    
                case let .groupChallengeCreate(store):
                    ChallengeGroupCreateView(store: store)
                        .disableBackGesture(false)
                }
            }
        }
    }
}

extension ChallengeTabScreen.State: Identifiable {
    public var id: ID {
        switch self {
        case .home:
            return .home
        case .groupChallengeCreate:
            return .groupChallengeCreate
        }
    }
    
    public enum ID: Identifiable {
        case home
        case groupChallengeCreate
        
        public var id: ID {
            return self
        }
    }
}
