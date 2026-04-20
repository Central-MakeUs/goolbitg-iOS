//
//  HomeTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import SwiftUI
import ComposableArchitecture
import FeatureCommon

public struct HomeTabCoordinatorView: View {
    
    public init(store: StoreOf<HomeTabCoordinator>) {
        self.store = store
    }
    
    @Perception.Bindable var store: StoreOf<HomeTabCoordinator>
    
    public var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension HomeTabCoordinatorView {
    private var content: some View {
        GBHomeTabViewV1(store: store.scope(state: \.home, action: \.home))
            .disableBackGesture(false)
        .fullScreenCover(
            isPresented: Binding(
                get: { store.pushList != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.pushList(.delegate(.dismiss)))
                    }
                }
            )
        ) {
            if let pushListStore = store.scope(state: \.pushList, action: \.pushList) {
                PushListView(store: pushListStore)
            }
        }
    }
}
