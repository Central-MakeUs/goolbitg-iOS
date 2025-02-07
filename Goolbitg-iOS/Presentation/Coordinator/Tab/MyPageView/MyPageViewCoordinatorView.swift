//
//  MyPageViewCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct MyPageViewCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<MyPageTabCoordinator>
    
    
    var body: some View {
        WithPerceptionTracking {
            content
        }
    }
}

extension MyPageViewCoordinatorView {
    private var content: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .home(store):
                MyPageView(store: store)
            case let .revokePage(store):
                RevokeReasonView(store: store)
                    .navigationBarBackButtonHidden()
                    .disableBackGesture(false)
            }
        }
    }
}


extension MyPageScreen.State: Identifiable {
    
    var id: ID {
        switch self {
        case .home:
            return .home
        case .revokePage:
            return .revokePage
        }
    }
    
    enum ID: Identifiable {
        case home
        case revokePage
        
        var id: ID {
            return self
        }
    }
}
