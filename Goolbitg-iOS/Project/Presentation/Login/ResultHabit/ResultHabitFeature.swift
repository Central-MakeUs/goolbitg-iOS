//
//  ResultHabitFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ResultHabitFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        let userModel: UserInfoDTO
        var resultModel: UserHabitResultEntity = UserHabitResultEntity(
            topTitle: " ",
            stepTitle: " ",
            nameTitle: " ",
            imageUrl: nil,
            shareImageUrl: nil,
            spendingScore: " ",
            sameCount: " "
        )
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case nextView
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case fitHabitStartTapped
    }
    enum FeatureEvent {
        case requestUserResult
    }
    
    @Dependency(\.userMapper) var userMapper
    
    var body: some ReducerOf<Self> {
        core
    }
    
}

extension ResultHabitFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action  {
            
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.featureEvent(.requestUserResult))
                }
            case .featureEvent(.requestUserResult):
                let result = userMapper.resultHabitMapping(model: state.userModel)
                state.resultModel = result
                
            case .viewEvent(.fitHabitStartTapped):
                return .send(.delegate(.nextView))
                
            default:
                break
            }
            return .none
        }
    }
}
