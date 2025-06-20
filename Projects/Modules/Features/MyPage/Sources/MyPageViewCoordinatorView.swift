//
//  MyPageViewCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
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
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .home(store):
                MyPageView(store: store)
                    .hiddenNavigationBar()
            case let .revokePage(store):
                RevokeReasonView(store: store)
                    .navigationBarBackButtonHidden()
                    .disableBackGesture(false)
                
            case let .pushList(store):
                PushListView(store: store)
            }
        }
    }
}


extension MyPageScreen.State: Identifiable {
    
    public var id: ID {
        switch self {
        case .home:
            return .home
        case .revokePage:
            return .revokePage
        case .pushList:
            return .pushList
        }
    }
    
    public enum ID: Identifiable {
        case home
        case revokePage
        case pushList
        
        public var id: ID {
            return self
        }
    }
}
