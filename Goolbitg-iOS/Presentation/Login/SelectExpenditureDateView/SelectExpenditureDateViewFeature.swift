//
//  SelectExpenditureDateViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/13/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ExpressExpenditureDateViewFeature {
    
    @ObservableState
    struct State: Equatable {
        var selectedWeak: WeakEnum? = nil
        var selectedDate = Date()
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case returnAction(ReturnAction)
        
        // Binding
        case selectedDate(Date)
    }
    
    enum ViewEvent {
        case selectedWeak(WeakEnum)
        case nextButtonTapped
        case skipClicked
    }
    
    enum ReturnAction {
        
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension ExpressExpenditureDateViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewEvent(.selectedWeak(let item)):
                state.selectedWeak = item
             
            case .selectedDate(let date):
                state.selectedDate = date
                
            default:
                break
            }
            return .none
        }
    }
}
