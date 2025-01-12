//
//  ComsumptionHabitsViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/12/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ComsumptionHabitsViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        
        var closeToolTipTrigger = false
        
        var monthGetText: String = ""
        var getisFocused: Bool = false
        
        var monthSavingText: String = ""
        var savingIsFocused: Bool = false
        
        var monthTextGetWonState = false
        var monthTextSavingWonState = false
        var ifNextButtonState: Bool = false
        
        var ifMoreGetting: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case returnToEvent(ReturnToEvent)
        
        /// dummyForButtonState or Focus
        case dummyButtonState(Bool)
        
        // Binding
        case monthGetText(String)
        case monthSavingText(String)
        
        case getFocused(Bool)
        case savingFocused(Bool)
    }
    
    enum ViewCycle {}
    
    enum ViewEvent {
        
        case showToolTopEvent
        
        case nextButtonTapped
    }
    
    enum ReturnToEvent {
        case closeToolTip
        case showNoticeMoreSaving(Bool)
        
        case checkToMonthText(String)
        case checkToSavingText(String)
    }
    
    enum DataTransformable {}
    
    @Dependency(\.gbNumberForMatter) var gbNumberForMatter
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension ComsumptionHabitsViewFeature {
    private var core: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .viewEvent(.showToolTopEvent):
                return .run { send in
                    try? await Task.sleep(for: .seconds(2))
                    await send(.returnToEvent(.closeToolTip))
                }
                
            case .viewEvent(.nextButtonTapped):
                print("ASASASAS")
                
            case .monthGetText(let text):
                return .run { send in
                    await send(.returnToEvent(.checkToMonthText(text)))
                }
            case .monthSavingText(let text):
                return .run { send in
                    await send(.returnToEvent(.checkToSavingText(text)))
                }
                
            case .returnToEvent(.closeToolTip):
                
                state.closeToolTipTrigger.toggle()
                
            case .returnToEvent(.checkToMonthText(let text)):
                state.monthTextGetWonState = !text.isEmpty
                
                let result = gbNumberForMatter.changeForCommaNumber(text)
                state.monthGetText = result
                
                return checkNextButtonState(state: &state)
                
                
            case .returnToEvent(.checkToSavingText(let text)):
                state.monthTextSavingWonState = !text.isEmpty
                
                let result = gbNumberForMatter.changeForCommaNumber(text)
                state.monthSavingText = result
                
                return checkNextButtonState(state: &state)
                
            case .returnToEvent(.showNoticeMoreSaving(let bool)):
                state.ifMoreGetting = bool
                
            case .getFocused(let bool):
                state.getisFocused = bool
                
            case .savingFocused(let bool):
                state.savingIsFocused = bool
                
            
                
            default:
                break
            }
            return .none
        }
    }
}

extension ComsumptionHabitsViewFeature {
    private func checkNextButtonState(state: inout State) -> Effect<Action> {
        
        let monthGet = state.monthGetText
        let monthSaving = state.monthSavingText
        
        if !monthGet.isEmpty && !monthSaving.isEmpty {
            let getRemoveComma = monthGet.replacingOccurrences(of: ",", with: "")
            let savingRemoveComma = monthSaving.replacingOccurrences(of: ",", with: "")
            
            let getInt = Int(getRemoveComma) ?? 0
            let savingInt = Int(savingRemoveComma) ?? 0
            
            if savingInt > getInt {
                state.ifNextButtonState = false
                return .send(.returnToEvent(.showNoticeMoreSaving(true)))
            } else {
                state.ifNextButtonState = true
                return .send(.returnToEvent(.showNoticeMoreSaving(false)))
            }
        }
        state.ifNextButtonState = false
        return .send(.returnToEvent(.showNoticeMoreSaving(false)))
    }
}
