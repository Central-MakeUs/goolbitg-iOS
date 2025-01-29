//
//  RootCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct RootCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<RootCoordinator>
    
    @State private var currentView: RootCoordinator.ChangeRootView = .splashLogin
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onChange(of: store.currentView) { newValue in
                    withAnimation {
                        currentView = newValue
                    }
                }
        }
    }
}


extension RootCoordinatorView {
    private var content: some View {
        VStack {
            switch currentView {
            case .splashLogin:
                SplashLoginCoordinatorView(
                    store: store.scope(
                        state: \.splashLogin,
                        action: \.splashLoginAction
                    )
                )
                
            case .mainTab:
                GBTabBarView(
                    store: store.scope(
                        state: \.tabState,
                        action: \.tabAction
                    )
                )
            }
        }
    }
}


#Preview {
    RootCoordinatorView(store: Store(
        initialState: RootCoordinator.State(),
        reducer: {
            RootCoordinator()
        }))
}
