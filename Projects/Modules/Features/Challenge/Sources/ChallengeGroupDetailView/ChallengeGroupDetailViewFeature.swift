//
//  ChallengeGroupDetailViewFeature.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 7/8/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct ChallengeGroupDetailViewFeature: GBReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
        var onAppearTrigger = false
        let groupId: String
        var challengeEntityState: ParticipatingGroupChallengeListEntity = ParticipatingGroupChallengeListEntity(id: 9999, ownerId: "...", title: "Loading", totalWithParticipatingPeopleCount: "loading", hashTags: [], reward: "Loading", isSecret: false)
        var challengeStatus: [ChallengeStatusCase] = [.none, .wait, .wait]
        var topPodiumModels: [ChallengeRankEntity] = []
        var bottomListModels: [ChallengeRankEntity] = []
        var showErrorMessage: String? = nil
        
        public init(groupID: String) {
            self.groupId = groupID
        }
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        // Binding
        case showErrorMessage(message: String?)
        
        public enum Delegate {
            case back
        }
    }
    
    public enum ViewEvent {
        
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum FeatureEvent {
        case requestChallengeGroupDetail(groupID: String)
        
        case topRankUpdated([ChallengeRankEntity])
        case bottomRankUpdated([ChallengeRankEntity])
        case challengeInfoUpdate(ParticipatingGroupChallengeListEntity)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeGroupDetailViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // MARK: ViCycle
            case .viewCycle(.onAppear):
                if state.onAppearTrigger { return .none }
                state.onAppearTrigger = true
                
                return .send(.featureEvent(.requestChallengeGroupDetail(groupID: state.groupId)))
                
                
            // MARK: FeatureEvent
            case let .featureEvent(.requestChallengeGroupDetail(groupID)):
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: GroupChallengeDetailDTO.self,
                        router: ChallengeRouter.groupChallengeDetail(groupID: groupID)
                    )
                    
                    let challengeMapping = challengeMapper.toMappingGroupChallenge(dto: result.group)
                    
                    await send(.featureEvent(.challengeInfoUpdate(challengeMapping)))
                    
                    let mappingRank = await challengeMapper.toMappingGroupChallengeRank(dtos: result.rank)
                    
                    if mappingRank.count < 4 {
                        await send(.featureEvent(.bottomRankUpdated(mappingRank)))
                    } else {
                        let front = Array(mappingRank.prefix(3))
                        let back = Array(mappingRank.dropFirst(3))
                        
                        await send(.featureEvent(.topRankUpdated(front)))
                        await send(.featureEvent(.bottomRankUpdated(back)))
                    }
                    
                } catch: { error, send in
                    if let error = error as? RouterError {
                        if case .serverMessage(let model) = error {
                            if model.rawValue == 4004 {
                                await send(.showErrorMessage(message: "챌린지가 존재하지 않습니다."))
                            }
                        }
                    } else {
                        await send(.showErrorMessage(message: "문제가 발생하였습니다."))
                    }
                }
                
            case let .featureEvent(.challengeInfoUpdate(entity)):
                state.challengeEntityState = entity
                
            case let .featureEvent(.bottomRankUpdated(entitys)):
                state.bottomListModels = entitys
                
            case let .featureEvent(.topRankUpdated(entitys)):
                state.topPodiumModels = entitys
                
            // MARK: Binding
            case let .showErrorMessage(message):
                state.showErrorMessage = message
                
            default:
                break
            }
            return .none
        }
    }
}
