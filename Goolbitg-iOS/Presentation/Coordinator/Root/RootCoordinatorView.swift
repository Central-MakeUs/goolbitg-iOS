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
    
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}


extension RootCoordinatorView {
    private var content: some View {
        VStack {
            switch store.currentView {
            case .splashLogin:
                SplashLoginCoordinatorView(
                    store: store.scope(
                        state: \.splashLogin,
                        action: \.splashLoginAction
                    )
                )
                
            case .mainTab:
                EmptyView()
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
