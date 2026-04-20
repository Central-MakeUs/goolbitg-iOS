//
//  ChallengeTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import SwiftUI
import ComposableArchitecture
import Utils
import FeatureCommon

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
        ChallengeTabView(store: store.scope(state: \.home, action: \.home))
            .disableBackGesture(false)
        .fullScreenCover(
            isPresented: Binding(
                get: { store.groupChallengeCreate != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.groupChallengeCreate(.delegate(.dismiss)))
                    }
                }
            )
        ) {
            if let createStore = store.scope(state: \.groupChallengeCreate, action: \.groupChallengeCreate) {
                ChallengeGroupCreateView(store: createStore)
                    .disableBackGesture(false)
            }
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { store.groupChallengeSearch != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.groupChallengeSearch(.delegate(.backButtonTapped)))
                    }
                }
            )
        ) {
            if let searchStore = store.scope(state: \.groupChallengeSearch, action: \.groupChallengeSearch) {
                ChallengeGroupSearchView(store: searchStore)
                    .disableBackGesture(false)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}
