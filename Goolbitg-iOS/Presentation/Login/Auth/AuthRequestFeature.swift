//
//  AuthRequestFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AuthRequestFeature {
    
    @ObservableState
    struct State: Equatable {
        var nickName: String = ""
        var birthDayYear = ""
        var birthDayMonth = ""
        var birthDayDay = ""
        
        var isYearFocused = false
        var isMonthFocused = false
        var isDayFocused = false
        
        var date = Date()
        
        var currentGender: GenderType? = nil
        
        var requiredCheckedList = RequiredCheckedList()
        var isActionButtonState = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        // TextBinding
        case nickNameText(String)
        case yearText(String)
        case monthText(String)
        case dayText(String)
        
        // TextField Focused
        case moveToTarget(KeyboardTarget)
        
        case yearFocused(Bool)
        case monthFocused(Bool)
        case dayFocused(Bool)
        
        // TextFieldIssue
        case nickNameTextChecker(String)
        case monthTextChecker(String)
        case dayTextChecker(String)
        case yearTextChecker(String)
    }
    
    enum ViewEvent: Equatable {
        case maleTaped
        case femaleTapped
    }
    
    struct RequiredCheckedList: Equatable {
        var nickName: Bool = false
        var nickNameDuplicated: Bool = false
        var year: Bool = false
        var month: Bool = false
        var day: Bool = false
        var gender: Bool = false
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .nickNameText(let text):
                state.nickName = text
        
                return .run { send in
                    try? await Task.sleep(for: .milliseconds(80))
                    await send(.nickNameTextChecker(text))
                }
                
            case .yearText(let text):
                state.birthDayYear = text
                
                if text.count >= 4 {
                    return .run { send in
                        await send(.moveToTarget(.month))
                        await send(.yearTextChecker(text))
                    }
                }
                
                
            case .monthText(let text):
                state.birthDayMonth = text
                
                if text.count >= 2 {
                    return .run { send in
                        await send(.monthTextChecker(text))
                        await send(.moveToTarget(.day))
                    }
                }
                
            case .dayText(let text):
                state.birthDayDay = text
                
                if text.count >= 2 {
                    return .run { [state] send in
                        await send(.moveToTarget(.done))
                        await send(.yearTextChecker(state.birthDayYear))
                        await send(.monthTextChecker(state.birthDayMonth))
                        await send(.dayTextChecker(state.birthDayDay))
                    }
                }
                
            case .yearFocused(let bool):
                if bool {
                    return .run { send in
                        await send(.moveToTarget(.year))
                    }
                }
                
            case .monthFocused(let bool):
                if bool {
                    return .run { send in
                        await send(.moveToTarget(.month))
                    }
                }
            case .dayFocused(let bool):
                if bool {
                    return .run { send in
                        await send(.moveToTarget(.day))
                    }
                }
                
            case .nickNameTextChecker(let text):
                let removeNext = text.removeNextLine
                let removeSpacing = removeNext.removeSpacing
                print(removeSpacing)
                state.nickName = removeSpacing
                
            case .monthTextChecker(let text):
                checkToMonth(state: &state, input: text)
                
            case .dayTextChecker(let text):
                checkToDay(state: &state, input: text)
                
            case .yearTextChecker(let text):
                checkToYear(state: &state, input: text)
                
            case .moveToTarget(let target):
                return targetKeyBoard(state: &state, target: target)
            
                
            case .viewEvent(.maleTaped):
                state.currentGender = .male
                
            case .viewEvent(.femaleTapped):
                state.currentGender = .female
                
            }
            return .none
        }
    }
}


extension AuthRequestFeature {
    
    enum KeyboardTarget {
        case year
        case month
        case day
        
        case done
    }
    
    private func targetKeyBoard(state: inout State, target: KeyboardTarget) -> Effect<Action> {
        switch target {
        case .year:
            state.birthDayYear = ""
            state.isMonthFocused = false
            state.isDayFocused = false
            state.isYearFocused = true
        case .month:
            state.birthDayMonth = ""
            state.isYearFocused = false
            state.isDayFocused = false
            state.isMonthFocused = true
        case .day:
            state.birthDayDay = ""
            state.isYearFocused = false
            state.isMonthFocused = false
            state.isDayFocused = true
        case .done:
            state.isYearFocused = false
            state.isMonthFocused = false
            state.isDayFocused = false
        }
        return .none
    }
    
    private func checkRequired(state: inout State) {
        let list = state.requiredCheckedList
        
        let bool = list.nickName && list.nickNameDuplicated && list.year && list.month && list.day && list.gender
    
        state.isActionButtonState = bool
    }
    
    private func checkToYear(state: inout State, input: String) {
        guard let yearInt = Int(input) else {
            return
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let minYear = currentYear - 200
        
        if yearInt > currentYear {
            state.birthDayYear = String(currentYear)
        } else if yearInt < minYear {
            state.birthDayYear = String(currentYear)
        } else {
            state.birthDayYear = String(yearInt)
        }
    }
    
    private func checkToMonth(state: inout State, input: String) {
        guard let monthInt = Int(input) else {
            state.birthDayMonth = ""
            return
        }
        if monthInt < 1 {
            state.birthDayMonth = ""
        } else if monthInt > 12 {
            state.birthDayMonth = ""
        } else {
            state.birthDayMonth = String(format: "%02d", monthInt)
        }
    }
    
    private func checkToDay(state: inout State, input: String) {
        guard let dayInt = Int(input) else {
            state.birthDayDay = ""
            return
        }
        if dayInt < 1 {
            state.birthDayDay = ""
        } else if dayInt > 31 {
            state.birthDayDay = ""
        } else {
            state.birthDayDay = String(format: "%02d", dayInt)
        }
    }
    
}
