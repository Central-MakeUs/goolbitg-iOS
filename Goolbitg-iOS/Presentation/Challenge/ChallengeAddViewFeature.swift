//
//  ChallengeAddViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChallengeAddViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var currentFamousList: [ChallengeEntity]? = nil
        var currentAnotherList: [ChallengeEntity]? = nil
        var dismissButtonHidden: Bool
        var selectedEntity: ChallengeEntity? = nil
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case dismissTapped
        }
        case selectedEntityBinding(ChallengeEntity?)
    }
    
    var body: some ReducerOf<Self> {
        core
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case dismissButtonTapped
        case selectedChallenge(ChallengeEntity)
        case tryButtonTapped
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    enum FeatureEvent {
        case requestAPIForChallengeList
        case setFamousList([ChallengeEntity])
        case setAnotherList([ChallengeEntity])
    }
}

extension ChallengeAddViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    try? await Task.sleep(for: .seconds(1))
                    await send(.featureEvent(.requestAPIForChallengeList))
                }
                
            case .featureEvent(.requestAPIForChallengeList):
                // MARK: 유형별 다시 꽃아놓기
                let userHabitType: Int? = nil // UserDefaultsManager.userHabitType
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(dto: ChallengeListDTO.self, router: ChallengeRouter.challengeList(spendingTypeID: userHabitType))
                    
                    let mapping = await challengeMapper.toEntity(dto: result)
                    
                    await send(.featureEvent(.setFamousList(mapping)))
                    await send(.featureEvent(.setAnotherList(mapping)))
                    
                } catch: { error, send in
                    Logger.error(error)
                }
                
            case let .featureEvent(.setFamousList(models)):
                let result = Array(models.prefix(3))
                
                state.currentFamousList = result
                
            case let .featureEvent(.setAnotherList(models)):
                let result = Array(models.dropFirst(3))

                state.currentAnotherList = result
                
            case .viewEvent(.dismissButtonTapped):
                return .send(.delegate(.dismissTapped))
                
            case let .viewEvent(.selectedChallenge(data)):
                // 팝업 띄우기
                state.selectedEntity = data
                
            case let .selectedEntityBinding(value):
                state.selectedEntity = value
                
            case .viewEvent(.tryButtonTapped):
                // 팝업 내리기
                state.selectedEntity = nil
                // 챌린지 Add 달아놓으세요 
                
            default:
                break
            }
            return .none
        }
    }
}
