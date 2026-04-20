//
//  MyPageViewCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import SwiftUI
import ComposableArchitecture
import FeatureCommon

public struct MyPageViewCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<MyPageTabCoordinator>
    
    public init(store: StoreOf<MyPageTabCoordinator>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension MyPageViewCoordinatorView {
    private var content: some View {
        MyPageView(store: store.scope(state: \.home, action: \.home))
        .fullScreenCover(
            isPresented: Binding(
                get: { store.revokePage != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.revokePage(.delegate(.dismiss)))
                    }
                }
            )
        ) {
            if let revokeStore = store.scope(state: \.revokePage, action: \.revokePage) {
                RevokeReasonView(store: revokeStore)
                    .navigationBarBackButtonHidden()
                    .disableBackGesture(false)
            }
        }
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
