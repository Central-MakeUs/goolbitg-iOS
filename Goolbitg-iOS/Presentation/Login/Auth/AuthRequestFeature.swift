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
    
    enum BirthDayShowTextState {
        case show
        case placeholder
    }
    
    @ObservableState
    struct State: Equatable {
        var nickName: String = ""
        var birthDayText = ""
        
        var maxCalendar = Calendar.current.date(byAdding: .year, value: -100, to: Date())!...Date()
        
        var birthDayShowTextState: BirthDayShowTextState = .placeholder
        var date = Date()
        var currentGender: GenderType? = nil
        
        var isDuplicateButtonState = false
        var isActionButtonState = false
        var nickNameResult: NickNameValidateEnum = .none
        var dateState: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        // TextBinding
        case nickNameText(String)

        case nickNameTextChecker(String)
        
        case selectedDate(Date)
    }
    
    enum ViewEvent: Equatable {
        case maleTaped
        case femaleTapped
        case duplicatedButtonTapped
        case nickNameTextFieldEventEnd
    }
    
    @Dependency(\.dateManager) var dateFormatter
    @Dependency(\.textValidManager) var textValidManager
    
    static let test = "test"
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .nickNameText(let text):
//                return .send(.nickNameTextChecker(text))
                return .run { send in
                    await send(.nickNameTextChecker(text))
                }
                
            case .nickNameTextChecker(let text):
                let removeNext = text.removeNextLine
                let removeSpacing = removeNext.removeSpacing
                
                print(removeSpacing, text)
                if text != state.nickName {
                    state.nickName = removeSpacing
                }
                
                if !text.isEmpty {
                    let result = nickNameTextCheck(nickName: removeSpacing)
                    state.nickNameResult = result
                    state.isDuplicateButtonState = ((result == .none) && !removeSpacing.isEmpty)
                }

                checkedButtonState(state: &state)
                
            case .selectedDate(let date):
                state.date = date
                let dateString = mappingToStringDate(date: date)
                
                state.birthDayText = dateString
                state.birthDayShowTextState = .show
                
                state.dateState = true
                checkedButtonState(state: &state)
                
            case .viewEvent(.maleTaped):
                state.currentGender = .male
                checkedButtonState(state: &state)
                
            case .viewEvent(.femaleTapped):
                state.currentGender = .female
                checkedButtonState(state: &state)
                
                /// 통신해야함 중복 검사
            case .viewEvent(.duplicatedButtonTapped):
                state.nickNameResult = .active
                checkedButtonState(state: &state)
                
            case .viewEvent(.nickNameTextFieldEventEnd):
                state.nickName = state.nickName.replacingOccurrences(of: ".", with: "")
            }
            
            
            return .none
        }
    }
}

extension AuthRequestFeature {
    
    private func nickNameTextCheck(nickName: String) -> NickNameValidateEnum {
        
        if !((nickName.count >= 2) && (nickName.count <= 6)) {
            return .limitOverOrUnder
        }
        
        if !textValidManager.textValidCheck(validMode: .nickNameKoreanAndEnglish, text: nickName) {
            return .denied
        }
        
        return .none
    }
    
    private func mappingToStringDate(date: Date) -> String {
        return dateFormatter.dateFormatToBirthDay(date)
    }
    
    private func checkedButtonState(state: inout State) {
        let nickNameState = state.nickNameResult == .active
        let birthDayState = state.dateState
        let genderState = state.currentGender != nil
        
        print(nickNameState, birthDayState, genderState)
        
        state.isActionButtonState = nickNameState && birthDayState && genderState
    }
}
