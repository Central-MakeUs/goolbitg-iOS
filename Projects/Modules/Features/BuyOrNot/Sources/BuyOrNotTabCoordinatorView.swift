//
//  BuyOrNotTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import Utils

public struct BuyOrNotTabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<BuyOrNotTabCoordinator>
    
    public init(store: StoreOf<BuyOrNotTabCoordinator>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .home(store):
                    BuyOrNotTabView(store: store)
                        .hiddenNavigationBar()
                case let .buyOrNotAdd(store):
                    BuyOrNotAddView(store: store)
                    
                }
            }
        }
    }
}

extension BuyOrNotTabCoordinatorScreen.State: Identifiable {
    
    public var id: ID {
        switch self {
        case .home:
            return .home
        case .buyOrNotAdd:
            return .add
        }
    }
    
    public enum ID: Identifiable {
        case home
        case add
        
        public var id: ID {
            return self
        }
    }
}
