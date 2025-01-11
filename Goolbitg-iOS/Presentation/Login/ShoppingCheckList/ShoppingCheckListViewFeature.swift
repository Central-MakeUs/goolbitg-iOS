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
    struct State {
        var isShowView: Bool = false
        var buttonState: Bool = false
        
        var mockDatas: [MockData] = [
            .init(checkState: false, titel: "모든게 낮설기만해"),
            .init(checkState: false, titel: "꿈을 꾸었나"),
            .init(checkState: false, titel: "살얼이 놧다."),
            .init(checkState: false, titel: "커피 3잔에 여유"),
            .init(checkState: false, titel: "람보르기니 긁어보기"),
            .init(checkState: false, titel: "포르쉐 긁어보기"),
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
