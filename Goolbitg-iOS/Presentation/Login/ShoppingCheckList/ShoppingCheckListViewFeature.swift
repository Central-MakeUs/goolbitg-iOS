//
//  ShoppingCheckListViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture

struct MockData: Equatable, Hashable {
    var checkState: Bool
    let titel: String
}

@Reducer
struct ShoppingCheckListViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var isShowView: Bool = false
        var buttonState: Bool = false
        
        var mockDatas: [MockData] = [
            MockData(checkState: false, titel: TextHelper.checkList1),
            MockData(checkState: false, titel: TextHelper.checkList2),
            MockData(checkState: false, titel: TextHelper.checkList3),
            MockData(checkState: false, titel: TextHelper.checkList4),
            MockData(checkState: false, titel: TextHelper.checkList5),
            MockData(checkState: false, titel: TextHelper.checkList6),
        ]
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case dataTransformable(DataTransformable)
        
        /// Binding
        case buttonState(Bool)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case selectedCheckListElement(data: MockData, idx: Int)
        case nextButtonTapped
    }
    
    enum DataTransformable {
        
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension ShoppingCheckListViewFeature {
    
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.isShowView = true
                
            case .viewEvent(.selectedCheckListElement( _, let idx)):
                state.mockDatas[idx].checkState.toggle()
                checkButtonState(state: &state)
                
                // buttonState
            case .buttonState(let bool):
                state.buttonState = bool
            default :
                break
            }
            return .none
        }
    }
    
    private func checkButtonState(state: inout State) {
        let checked = state.mockDatas.filter { $0.checkState == true }
        let checkResult = !checked.isEmpty
        state.buttonState = checkResult
    } 
}
