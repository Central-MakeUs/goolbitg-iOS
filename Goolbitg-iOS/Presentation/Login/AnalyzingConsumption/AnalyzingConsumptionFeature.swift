//
//  AnalyzingConsumptionFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AnalyzingConsumptionFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {}
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tossToResult(UserInfoDTO)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case backButtonTapped
    }
    
    enum FeatureEvent {
        case requestUserInfo
        case resultUserInfo(UserInfoDTO)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension AnalyzingConsumptionFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                
                return .run { send in
                    await send(.featureEvent(.requestUserInfo))
                }
                
            case .featureEvent(.requestUserInfo):
                
                return .run { send in
                    Logger.info(UserDefaultsManager.accessToken)
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: UserInfoDTO.self,
                        router: UserRouter.currentUserInfos
                    )
                    try? await Task.sleep(for: .seconds(1))
                    
                    await send(.featureEvent(.resultUserInfo(result)))
                    
                } catch: { error, send in
                    Logger.error(error)
                }
                
            case let .featureEvent(.resultUserInfo(model)):
                // MARK: 유저 소비유형 저장 시점
                UserDefaultsManager.userHabitType = model.spendingType.id
                
                return .send(.delegate(.tossToResult(model)))
                
            default :
                break
            }
            return .none
        }
    }
}
