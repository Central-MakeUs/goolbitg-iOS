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
        var date = Date()
        var isActionButtonState = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        
        // TextBinding
        case nickNameText(String)
        case yearText(String)
        case monthText(String)
        case dayText(String)
    }
    
    enum ViewEvent {
        
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .nickNameText(let text):
                state.nickName = text
                
            case .yearText(let text):
                state.birthDayYear = text
                
            case .monthText(let text):
                state.birthDayMonth = text
                
            case .dayText(let text):
                state.birthDayDay = text
                
            default:
                break
            }
            return .none
        }
    }
}
