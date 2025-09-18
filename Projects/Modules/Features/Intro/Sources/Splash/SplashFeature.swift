//
//  SplashFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SplashFeature {
    
    @ObservableState
    public struct State: Equatable, Hashable {}
    
    public enum Action {
        case viewCycle(ViewCycle)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case finish
        }
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public var body : some ReducerOf<Self> {
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
