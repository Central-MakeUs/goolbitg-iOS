//
//  ResultHabitFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture
import Domain
import Data

@Reducer
public struct ResultHabitFeature: GBReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
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
        
        public init(userModel: UserInfoDTO) {
            self.userModel = userModel
        }
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        public enum Delegate {
            case nextView
        }
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case fitHabitStartTapped
    }
    public enum FeatureEvent {
        case requestUserResult
    }
    
    @Dependency(\.userMapper) var userMapper
    
    public var body: some ReducerOf<Self> {
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
