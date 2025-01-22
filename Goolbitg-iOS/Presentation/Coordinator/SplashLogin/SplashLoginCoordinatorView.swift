//
//  SplashLoginCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct SplashLoginCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<SplashLoginCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension SplashLoginCoordinatorView {
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
                    
                case let .authRequestPage(store):
                    AuthPageView(store: store)
                        .navigationBarBackButtonHidden()
                        .disableBackGesture()
                    
                }
            }
        }
    }
}

extension SplashLoginScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .login:
            return .login
        case .splash:
            return .splash
        case .authRequestPage:
            return .authRequestPage
        }
    }
    
    enum ID: Identifiable {
        case splash
        case login
        case authRequestPage
        
        var id: ID {
            return self
        }
    }
}
