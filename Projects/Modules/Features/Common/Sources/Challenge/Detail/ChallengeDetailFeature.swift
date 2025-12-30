//
//  ChallengeDetailFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct ChallengeDetailFeature: GBReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
        let challengeID: String
        
        var onLoad = false
        var entity = ChallengeTrippleEntity.getSelf
        var deleteAlertState: GBAlertViewComponents? = nil
        
        public init(
            challengeID: String,
            onLoad: Bool = false,
            entity: ChallengeTrippleEntity = ChallengeTrippleEntity.getSelf,
            deleteAlertState: GBAlertViewComponents? = nil
        ) {
            self.challengeID = challengeID
            self.onLoad = onLoad
            self.entity = entity
            self.deleteAlertState = deleteAlertState
        }
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        public enum Delegate {
            case dismissTap
        }
        
        case alertBinding(GBAlertViewComponents?)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case dismissTap
        case stopTap
        case acceptStop
        case selectedCaseItem(item: ChallengeStatusCase)
    }
    
    public enum FeatureEvent {
        case requestChallengeTripple
        case resultChallengeTripple(ChallengeTrippleEntity)
        
        case requestTodayChallengeCheck
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    public var body: some ReducerOf<Self> {
        core
        viewCore
    }
}

extension ChallengeDetailFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
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
                    guard case .serverMessage(_) = error else {
                        Logger.warning(error)
                        return
                    }
                    // MARK: 에러 대응 해야함.
                    
                }
                    .animation(.easeInOut)
                
            case let .featureEvent(.resultChallengeTripple(model)):
                state.entity = model
                state.onLoad = true
                
            case let .alertBinding(alert):
                state.deleteAlertState = alert
                
            default:
                break
            }
            return .none
        }
    }
}

// MARK: ViewCore
extension ChallengeDetailFeature {
    private var viewCore: some Reducer<ChallengeDetailFeature.State, ChallengeDetailFeature.Action> {
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
                        _ = try await networkManager.requestNetworkWithRefresh(
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
            case .viewEvent(.stopTap):
                
                let deleteAlertState = GBAlertViewComponents(
                    title: "챌린지 멈추기",
                    message: "지금 멈추면 앞으로 기록을 못해요",
                    cancelTitle: "취소",
                    okTitle: "멈추기",
                    alertStyle: .warning
                )
                
                state.deleteAlertState = deleteAlertState
                
            case .viewEvent(.acceptStop):
                let id = state.challengeID
                return .run { send in
                    try await networkManager.requestNotDtoNetwork(
                        router: ChallengeRouter.challengeRecordDelete(ChallengeID: id),
                        ifRefreshNeed: true
                    )
                    await send(.delegate(.dismissTap))
                } catch: { error, send in
                    guard error is RouterError else {
                        return
                    }
                    // TODO: 에러 대응 해야함.
                }
            default:
                break
            }
            return .none
        }
    }
}
