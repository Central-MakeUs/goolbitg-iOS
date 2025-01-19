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
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .splash(store):
                    SplashView(store: store)
                    
                case let .login(store):
                    GBLoginView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                }
            }
        }
    }
}

extension RootScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .login:
            return .login
        case .splash:
            return .splash
        }
    }
    
    enum ID: Identifiable {
        case splash
        case login
        
        var id: ID {
            return self
        }
    }
}

#Preview {
    RootCoordinatorView(store: Store(
        initialState: RootCoordinator.State.initialState,
        reducer: {
            RootCoordinator()
        }))
}
