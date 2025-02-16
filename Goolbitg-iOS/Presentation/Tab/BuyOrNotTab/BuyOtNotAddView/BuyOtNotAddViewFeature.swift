//
//  BuyOtNotAddViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BuyOrNotAddViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var currentImageData: Data? = nil // 무조건 JPEG 로 변환
        var alertComponents: GBAlertViewComponents? = nil
    }
    
    enum Action {
        case viewCycles(ViewCycle)
        case viewEvent(ViewEvent)
        
        case delegate(Delegate)
        
        case bindingAlertComponents(GBAlertViewComponents?)
        
        enum Delegate {
            case dismiss
        }
    }
    
    enum ViewCycle {
    
    }
    
    enum ViewEvent {
        case imageResults(Data?)
        case dismiss
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension BuyOrNotAddViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewEvent(.dismiss):
                return .send(.delegate(.dismiss))
                
            case let .viewEvent(.imageResults(data)):
                state.currentImageData = data
                
            case let .bindingAlertComponents(components):
                state.alertComponents = components
                
            default:
                break
            }
            return .none
        }
    }
}
