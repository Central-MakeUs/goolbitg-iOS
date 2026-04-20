//
//  BuyOrNotTabCoordinatorView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import ComposableArchitecture
import FeatureCommon

public struct BuyOrNotTabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<BuyOrNotTabCoordinator>
    
    public init(store: StoreOf<BuyOrNotTabCoordinator>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            BuyOrNotTabView(store: store.scope(state: \.home, action: \.home))
        }
    }
}
