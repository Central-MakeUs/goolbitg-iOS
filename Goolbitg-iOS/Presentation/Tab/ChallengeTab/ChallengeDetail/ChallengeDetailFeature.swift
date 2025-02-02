//
//  ChallengeDetailFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChallengeDetailFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        let challengeID: String
        
        var entity = ChallengeTrippleEntity.getSelf
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        enum Delegate {
            case dismissTap
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case dismissTap
        case stopTap
        case selectedCaseItem(item: ChallengeStatusCase)
    }
    
    enum FeatureEvent {
        case requestChallengeTripple
        case resultChallengeTripple(ChallengeTrippleEntity)
        
        case requestTodayChallengeCheck
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeDetailFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewCycle(.onAppear):
                
                return .send(.featureEvent(.requestChallengeTripple))
            
            case .viewEvent(.dismissTap):
                return .send(.delegate(.dismissTap))
                
            case let .viewEvent(.selectedCaseItem(item)):
                let id = state.challengeID
                if case .wait = item {
                    return .run { send in
                        let result = try await networkManager.requestNetworkWithRefresh(
                            dto: ChallengeRecordDTO.self,
                            router: ChallengeRouter.challengeRecordCheck(
                                challengeID: id
                            )
                        )
                        
                        await send(.delegate(.dismissTap))
                    } catch: { error, send in
                        guard let error = error as? RouterError else {
                            return
                        }
                        Logger.error(error)
                        /// MARK: 에러 대응 해야함
                    }
                }
                
            case .featureEvent(.requestChallengeTripple):
                let id = state.challengeID
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: ChallengeTrippleDTO.self,
                        router: ChallengeRouter.challengeTripple(challengeID: id)
                    )
                    let mapping = challengeMapper.toEntityTripple(dto: result)
                    
                    await send(.featureEvent(.resultChallengeTripple(mapping)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        Logger.warning(error)
                        return
                    }
                    guard case let .serverMessage(error) = error else {
                        Logger.warning(error)
                        return
                    }
                    // MARK: 에러 대응 해야함.
                    
                }
                
            case let .featureEvent(.resultChallengeTripple(model)):
                state.entity = model
                
            default:
                break
            }
            return .none
        }
    }
}
