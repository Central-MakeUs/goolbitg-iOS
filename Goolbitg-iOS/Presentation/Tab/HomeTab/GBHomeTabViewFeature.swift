//
//  GBHomeTabViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct GBHomeTabViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
    }
    
    enum ViewCycle {
        
    }
    enum ViewEvent {
        
    }
    enum FeatureEvent {
        
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension GBHomeTabViewFeature {
    var core: some ReducerOf<Self>{
        Reduce { state, action in
            switch action {
                
            default:
                break
            }
            return .none
        }
    }
}
