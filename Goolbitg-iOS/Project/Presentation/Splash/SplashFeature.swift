//
//  SplashFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature {
    
    @ObservableState
    struct State: Equatable {}
    
    enum Action {
        case viewCycle(ViewCycle)
        
        case delegate(Delegate)
        
        enum Delegate {
            case finish
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    var body : some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    try? await Task.sleep(for: .seconds(2))
                    await send(.delegate(.finish))
                }
            default:
                break
            }
            return .none
        }
    }
}
