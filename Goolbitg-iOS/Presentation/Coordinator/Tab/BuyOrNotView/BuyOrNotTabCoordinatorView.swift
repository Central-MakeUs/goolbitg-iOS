//
//  BuyOrNotTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct BuyOrNotTabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<BuyOrNotTabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .home(store):
                    BuyOrNotTabView(store: store)
                     
                case let .buyOrNotAdd(store):
                    BuyOrNotAddView(store: store)
                    
                }
            }
        }
    }
}

extension BuyOrNotTabCoordinatorScreen.State: Identifiable {
    
    var id: ID {
        switch self {
        case .home:
            return .home
        case .buyOrNotAdd:
            return .add
        }
    }
    
    enum ID: Identifiable {
        case home
        case add
        
        var id: ID {
            return self
        }
    }
}
