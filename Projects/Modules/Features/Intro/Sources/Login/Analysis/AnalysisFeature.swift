//
//  AnalysisFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/26/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AnalysisFeature {
    
    @ObservableState
    public struct State: Equatable, Hashable {
        public init () {}
    }
    
    public enum Action {
        case startButtonTapped
        
        case delegate(Delegate)
        
        public enum Delegate {
            case nextView
        }
    }
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension AnalysisFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                return .send(.delegate(.nextView))
                
            default:
                break
            }
            return .none
        }
    }
}
